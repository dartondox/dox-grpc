# dox_grpc

A gRPC server for the [Dox](https://dartondox.dev) framework.

You write your services with the classes that `protoc` makes, the same as with `package:grpc`. Dox serves them on its own native HTTP/2 server, on the same port as your HTTP routes. Normal Dox middleware runs before each call, so auth works the same way.

It supports the 4 call types (unary, server streaming, client streaming, bidi), deadlines, cancel, metadata, gzip, status details and the standard health service.

## Install

```bash
dart pub add dox_grpc
```

## Turn on HTTP/2

gRPC needs HTTP/2. Turn it on in `lib/config/app.dart`:

```dart
AppConfig appConfig = AppConfig(
  http2: true,
  // ...
);
```

The port then speaks HTTP/1.1 and HTTP/2 (h2c, no TLS). Put TLS on a proxy in front, eg. nginx with `grpc_pass grpc://app:3000` or Caddy with `reverse_proxy h2c://app:3000`.

## Write a service

Make the Dart code from your `.proto` file:

```bash
protoc --dart_out=grpc:lib/generated -Iprotos protos/greeter.proto
```

Then extend the generated base class:

```dart
import 'package:dox_grpc/dox_grpc.dart';

class GreeterService extends GreeterServiceBase {
  @override
  Future<HelloReply> sayHello(ServiceCall call, HelloRequest request) async {
    return HelloReply(message: 'Hello ${request.name}');
  }
}
```

## Register it

A service gets the route `POST /<package.Service>/{method}`. gRPC clients call that exact path, so register the service in a router with **no prefix**. A router without a `prefix` getter has none. Do not put it in the `api` router:

```dart
// no middleware: load balancers call the health check without a token
class HealthRouter extends Router {
  @override
  void register() {
    Grpc.register(HealthService());
  }
}

class GrpcRouter extends Router {
  @override
  List<dynamic> get middleware => <dynamic>[AuthMiddleware()];

  @override
  void register() {
    Grpc.register(GreeterService());
  }
}
```

The middleware of the router runs before each call. Keep the health service out of a router with auth middleware, or a load balancer's health check gets `UNAUTHENTICATED`. `Route.middleware([...], () => Grpc.register(...))` works too, but not for the first `Grpc.register` (see below). The gRPC routes skip `RequestTimeout`, so a long stream is not cut.

A call to a service that is not registered gets `UNIMPLEMENTED`, and so does a method the service does not have.

If a prefix or a `Route.group` changes the route path, `Grpc.register` throws a `StateError` at start. No client could reach that route. The first `Grpc.register` (for example, the `HealthService`) must be outside `Route.middleware`, because the `UNIMPLEMENTED` answer for unknown services is added with it. Later ones may be inside.

## Services run in every isolate

Dox runs your app in many isolates. A service is copied to each of them (a service made in a router is made again in each isolate). So a service must not hold a database connection, a socket or a `ReceivePort` in a field that is set when you register it. Those can not be copied. Create them lazily, inside the isolate, on first use:

```dart
class GreeterService extends GreeterServiceBase {
  Database? _db;

  // made on the first call, in the isolate that runs it
  Database get db => _db ??= Database.connect();

  @override
  Future<HelloReply> sayHello(ServiceCall call, HelloRequest request) async {
    User user = await db.findUser(request.name);
    return HelloReply(message: 'Hello ${user.name}');
  }
}
```

Or get the connection from a Dox provider, which runs in each isolate.

## Errors

Throw a `GrpcException` to end the call with a status:

```dart
throw GrpcException(GrpcStatus.notFound, 'No user 5');
```

The message is sent in `grpc-message`. Protobuf messages in `details` are sent in `grpc-status-details-bin`.

A `GrpcError` from `package:grpc` works the same way, so code from `package:grpc` keeps working. Any other error ends the call with `INTERNAL`. It is reported to the `ExceptionHandler` like other Dox errors. The client sees its text only when `APP_ENV` is `development` or `local`.

A middleware that throws a Dox HTTP error goes to the client as a gRPC error, with its message. 401 is `UNAUTHENTICATED`, 403 `PERMISSION_DENIED`, 404 `NOT_FOUND`, 422 `INVALID_ARGUMENT`, 429 `RESOURCE_EXHAUSTED` and 503 `UNAVAILABLE`.

## Metadata

- `call.clientMetadata` has the request headers, except the `grpc-*` ones.
- Set `call.headers` before the first message, and `call.trailers` before the end.
- The three maps are nullable in `ServiceCall`, so use `!`. In Dox they are always there until the call sends them.

```dart
String? requestId = call.clientMetadata!['x-request-id'];
call.headers!['x-request-id'] = requestId ?? 'none';
call.trailers!['x-done'] = 'yes';
```
- A `-bin` value stays base64 text, as in `package:grpc`. `GrpcWire.decodeBinary` gives its bytes (with or without padding), and `GrpcWire.encodeBinary` makes one.

## Deadlines and cancel

When the client set a deadline and it passes, the call ends with `DEADLINE_EXCEEDED` and `call.isTimedOut` is true. When the client cancels or leaves, `call.isCanceled` is true and the request stream ends. A long server stream should check `call.isCanceled`.

## Limits and gzip

```dart
Grpc.register(
  GreeterService(),
  options: GrpcOptions(
    maxReceiveMessageSize: 4 * 1024 * 1024,
    maxSendMessageSize: 4 * 1024 * 1024,
    gzipResponses: false,
    idleTimeout: Duration(minutes: 5),
  ),
);
```

- A message over the size limit ends the call with `RESOURCE_EXHAUSTED`. Both limits are 4 MiB by default, like other gRPC servers. The request limit also counts the bytes after unzip.
- Requests in gzip are always read. Responses are zipped only with `gzipResponses: true`, and only for clients that accept gzip. It is off by default, because it costs CPU on each message.
- `idleTimeout` is off by default. When it is set, a call with no message in or out for that long ends with `DEADLINE_EXCEEDED`. It frees the call of a client that never reads the answer, or a request that never ends (for example a unary call that never half-closes). The quiet time of your handler counts too, so set it longer than your slowest quiet handler. We suggest `Duration(minutes: 5)`. The deadline of the client (`grpc-timeout`) always works, with or without it.
- When one part of the body holds many zipped messages, they are unzipped one per event loop turn, so one stream can not hold the isolate. The unzipped size of each message is limited by `maxReceiveMessageSize`.
- A request error (a message that is too big, not valid, or cut short, or a second message in a unary call) reaches your method as an error in its request stream. A unary method is called only when its one message is complete.

## Health check

The standard `grpc.health.v1.Health` service, with `Check` and `Watch`:

```dart
HealthService health = HealthService();
Grpc.register(health);
health.setStatus('helloworld.Greeter', ServingStatus.SERVING);
```

The empty name `''` is the whole server and starts as `SERVING`. A change in one isolate goes to the other isolates of the app too (on the Dox `IsolateBus`). Each isolate joins when the server starts there, and its first `Check` or `Watch` waits a short time (up to 300 ms, once per isolate) for the other isolates to tell their status. Before the server starts, a status is only kept in the isolate (so a script that only loads the routes still exits).

## Tested with

- The gRPC interop suite: the grpc-go interop client runs `empty_unary`, `large_unary`, `client_streaming`, `server_streaming`, `ping_pong`, `empty_stream`, `timeout_on_sleeping_server`, `cancel_after_begin`, `cancel_after_first_response`, `status_code_and_message`, `special_status_message`, `custom_metadata`, `unimplemented_method` and `unimplemented_service` against a Dox server.
- `grpcurl` with `-plaintext` and `.proto` files: a unary call, a server stream and the health check.
- The same interop cases behind nginx (`grpc_pass grpc://...`) and Caddy (`reverse_proxy h2c://...`).
- The `package:grpc` client, in the tests of this repo (with gzip).

CI runs all of them on each change. See `ci/interop.sh`.

## Not yet

- Server reflection and gRPC-Web.
