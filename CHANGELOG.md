## Unreleased (3.3.0)

- First version. Serve `protoc`-generated gRPC services on the Dox HTTP/2 server with `Grpc.register(service)`. Unary, server streaming, client streaming and bidi calls, Dox middleware before each call, deadlines (`grpc-timeout`), cancel, metadata, `GrpcStatus` and `GrpcException` (a `GrpcError` from `package:grpc` works too), status details, gzip, message size limits (4 MiB by default), and the `grpc.health.v1` health service.
