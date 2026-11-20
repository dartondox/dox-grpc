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
class GrpcRouter extends Router {
  @override
  List<dynamic> get middleware => <dynamic>[AuthMiddleware()];

  @override
  void register() {
    Grpc.register(GreeterService());
  }
}
```

The middleware of the router runs before each call. `Route.middleware([...], () => Grpc.register(...))` works too. The gRPC routes skip `RequestTimeout`, so a long stream is not cut.

A call to a service that is not registered gets `UNIMPLEMENTED`, and so does a method the service does not have.

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
  ),
);
```

- A message over the size limit ends the call with `RESOURCE_EXHAUSTED`. Both limits are 4 MiB by default, like other gRPC servers. The request limit also counts the bytes after unzip.
- Requests in gzip are always read. Responses are zipped only with `gzipResponses: true`, and only for clients that accept gzip. It is off by default, because it costs CPU on each message.

## Health check

The standard `grpc.health.v1.Health` service, with `Check` and `Watch`:

```dart
HealthService health = HealthService();
Grpc.register(health);
health.setStatus('helloworld.Greeter', ServingStatus.SERVING);
```

The empty name `''` is the whole server and starts as `SERVING`. A change in one isolate goes to the other isolates of the app too (on the Dox `IsolateBus`).

## Not yet

- Server reflection and gRPC-Web.
