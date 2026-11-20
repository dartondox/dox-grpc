import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/src/grpc_call.dart';
import 'package:dox_grpc/src/grpc_options.dart';
import 'package:dox_grpc/src/native_stream.dart';
import 'package:grpc/service_api.dart';

/// Serves gRPC services on the Dox server.
///
/// Needs `http2: true` in the `AppConfig`. Register the services in a
/// route file (with no route prefix):
/// ```
/// Grpc.register(GreeterService());
///
/// // with middleware, eg. auth
/// Route.middleware(<dynamic>[AuthMiddleware()], () {
///   Grpc.register(AdminService());
/// });
/// ```
class Grpc {
  Grpc._();

  /// Adds the route `POST /<package.Service>/{method}` for [service]. A
  /// method the service does not have gets `UNIMPLEMENTED`.
  static void register(
    Service service, {
    GrpcOptions options = const GrpcOptions(),
  }) {
    GrpcServiceRoute route = GrpcServiceRoute(service, options);
    Route.post('/${service.$name}/{method}', route.handle);
  }
}

/// The route of one service. Checks the request, then runs a [GrpcCall].
class GrpcServiceRoute {
  GrpcServiceRoute(this.service, this.options);

  final Service service;
  final GrpcOptions options;

  /// Completes when the call ended. The answer is sent by then, so Dox has
  /// nothing more to send.
  Future<void> handle(DoxRequest req) {
    HttpRequest raw = req.httpRequest;
    NativeGrpcStream stream = NativeGrpcStream(raw);
    if (!isGrpcType(raw.headers.value(HttpHeaders.contentTypeHeader))) {
      stream.reject(
        HttpStatus.unsupportedMediaType,
        'content-type must be application/grpc',
      );
      return Future<void>.value();
    }
    if (!stream.isHttp2) {
      stream.reject(
        HttpStatus.httpVersionNotSupported,
        'gRPC needs HTTP/2 (set http2: true in the AppConfig)',
      );
      return Future<void>.value();
    }
    Object? name = req.param['method'];
    GrpcCall call = GrpcCall(
      stream,
      service,
      name is String ? service.$lookupMethod(name) : null,
      options,
      errors: Dox().config.exceptionHandler,
      request: raw,
      debug: Env.appEnv == 'development' || Env.appEnv == 'local',
    );
    return call.run();
  }

  /// `application/grpc` or `application/grpc+proto`, with any parameters
  static bool isGrpcType(String? value) {
    if (value == null) return false;
    String type = value.split(';').first.trim().toLowerCase();
    return type == 'application/grpc' || type == 'application/grpc+proto';
  }
}
