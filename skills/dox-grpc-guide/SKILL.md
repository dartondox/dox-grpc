---
name: dox-grpc-guide
description: Use when you add a gRPC service to a Dox (Dart) app with dox_grpc. Covers the .proto file, protoc, the service class, Grpc.register in a router with no prefix, the health service, GrpcOptions, errors and status codes, metadata, deadlines, and deployment over h2c behind nginx or Caddy.
---

# dox_grpc guide

`dox_grpc` serves gRPC services on the Dox server. The service code is the same as with `package:grpc`: you extend the class that `protoc` makes. Dox serves it on its native HTTP/2 port, next to your HTTP routes. Dox middleware runs before each call.

For routes, routers and app layout, see the `dox-core-guide` skill.

## 1. Install and turn on HTTP/2

```bash
dart pub add dox_grpc
```

gRPC needs HTTP/2. In `lib/config/app.dart`:

```dart
AppConfig appConfig = AppConfig(
  http2: true,
  // ...
);
```

The port then speaks HTTP/1.1 and cleartext HTTP/2 (h2c). There is no TLS in Dox. Put TLS on a proxy (see Deploy).

## 2. Write the .proto file and make the Dart code

`protos/greeter.proto`:

```proto
syntax = "proto3";
package helloworld;

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply);
}
message HelloRequest { string name = 1; }
message HelloReply { string message = 1; }
```

Install the Dart plugin once, then run protoc:

```bash
dart pub global activate protoc_plugin
protoc --dart_out=grpc:lib/generated -Iprotos protos/greeter.proto
```

Commit the generated files. Run protoc again after each `.proto` change.

## 3. Write the service

```dart
import 'package:dox_grpc/dox_grpc.dart';

import '../generated/greeter.pbgrpc.dart';

class GreeterService extends GreeterServiceBase {
  @override
  Future<HelloReply> sayHello(ServiceCall call, HelloRequest request) async {
    return HelloReply(message: 'Hello ${request.name}');
  }
}
```

- Unary: `Future<Reply> method(ServiceCall call, Request request)`.
- Server stream: return a `Stream<Reply>` (an `async*` method). Check `call.isCanceled` in long loops.
- Client stream and bidi: the request is a `Stream<Request>`.
- A service is copied to each isolate. Do not keep a database connection or socket in a field set at register time. Create it lazily on first use, or get it from a Dox provider.

## 4. Register it in a router with no prefix

gRPC clients call `POST /<package.Service>/<Method>`. So the router must have **no prefix**. Never use the `api` router. Register the health service first, in its own router with no auth middleware, so load balancers can call it:

```dart
class HealthRouter extends Router {
  @override
  void register() {
    HealthService health = HealthService();
    Grpc.register(health);
    health.setStatus('helloworld.Greeter', ServingStatus.SERVING);
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

Rules:
- A prefix or `Route.group` around `Grpc.register` throws a `StateError` at start.
- The first `Grpc.register` must not be inside `Route.middleware(...)`. Later ones may be.
- The health router must come first in `AppConfig.routers`.
- An unknown service or method gets `UNIMPLEMENTED`.
- gRPC routes skip `RequestTimeout`, so long streams are not cut.

## 5. Health

`HealthService` is the standard `grpc.health.v1.Health` (`Check` and `Watch`). The empty name `''` is the whole server and starts as `SERVING`. `health.setStatus(name, ServingStatus.NOT_SERVING)` in one isolate reaches all isolates.

## 6. Options

```dart
Grpc.register(
  GreeterService(),
  options: GrpcOptions(
    maxReceiveMessageSize: 4 * 1024 * 1024, // default 4 MiB
    maxSendMessageSize: 4 * 1024 * 1024, // default 4 MiB
    gzipResponses: false, // default off; gzip requests are always read
    idleTimeout: Duration(minutes: 5), // default 5 min; null = no limit; a quiet stream gets DEADLINE_EXCEEDED
  ),
);
```

## 7. Errors

```dart
throw GrpcException(GrpcStatus.notFound, 'No user 5');
```

- `GrpcError` from `package:grpc` works too.
- Any other error is `INTERNAL`. It goes to the `ExceptionHandler`. The client sees its text only when `APP_ENV` is `development` or `local`.
- A middleware HTTP error becomes a gRPC status: 401 `UNAUTHENTICATED`, 403 `PERMISSION_DENIED`, 404 `NOT_FOUND`, 422 `INVALID_ARGUMENT`, 429 `RESOURCE_EXHAUSTED`, 503 `UNAVAILABLE`.

## 8. Metadata and deadlines

The maps are nullable in `ServiceCall`, so use `!`:

```dart
String? id = call.clientMetadata!['x-request-id']; // no grpc-* headers here
call.headers!['x-request-id'] = id ?? 'none'; // before the first message
call.trailers!['x-done'] = 'yes'; // before the end
```

A `-bin` value is base64 text. Use `GrpcWire.decodeBinary` and `GrpcWire.encodeBinary`. When the client deadline passes, the call ends with `DEADLINE_EXCEEDED` and `call.isTimedOut` is true.

## 9. Test it

```bash
grpcurl -plaintext -import-path protos -proto greeter.proto \
  -d '{"name": "Ann"}' localhost:3000 helloworld.Greeter/SayHello
```

There is no server reflection yet, so `grpcurl` needs `-proto`. In Dart tests, use a `package:grpc` `ClientChannel` with `ChannelCredentials.insecure()`.

## 10. Deploy

Dox speaks h2c only. Put TLS on a proxy.

nginx (`http2 on;` is needed on the listen side):

```nginx
server {
  listen 443 ssl;
  http2 on;
  location / {
    grpc_pass grpc://app:3000;
  }
}
```

Caddy:

```
api.example.com {
  reverse_proxy h2c://app:3000
}
```

A load balancer should check `grpc.health.v1.Health/Check`.

## Not supported yet

Server reflection, gRPC-Web and Connect.
