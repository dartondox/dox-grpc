import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/src/grpc_call.dart';
import 'package:dox_grpc/src/grpc_options.dart';
import 'package:dox_grpc/src/grpc_status.dart';
import 'package:dox_grpc/src/native_stream.dart';
import 'package:dox_grpc/src/wire.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:grpc/service_api.dart';
import 'package:protobuf/protobuf.dart';

/// Serves gRPC services on the Dox server.
///
/// Needs `http2: true` in the `AppConfig`. Register the services in a
/// router with no prefix:
/// ```
/// class GrpcRouter extends Router {
///   @override
///   void register() {
///     Grpc.register(GreeterService());
///   }
/// }
/// ```
class Grpc {
  Grpc._();

  /// true once this isolate has the fallback for unknown services
  static bool _fallbackAdded = false;

  /// Adds the route `POST /<package.Service>/{method}` for [service]. A
  /// method the service does not have gets `UNIMPLEMENTED`. So does a
  /// gRPC call to a service that is not registered.
  ///
  /// The route skips `RequestTimeout`, so a long stream is not cut. Its
  /// errors (eg. a middleware that throws 401) go to the client as gRPC
  /// errors.
  static void register(
    Service service, {
    GrpcOptions options = const GrpcOptions(),
  }) {
    GrpcServiceRoute route = GrpcServiceRoute(service, options);
    Route.post('/${service.$name}/{method}', route.handle)
        .withoutMiddleware<RequestTimeout>()
        .renderErrorsWith(GrpcServiceRoute.renderError);
    if (_fallbackAdded) return;
    _fallbackAdded = true;
    Route.fallback(
      GrpcServiceRoute.unknownService,
      when: GrpcServiceRoute.isGrpcRequest,
    ).renderErrorsWith(GrpcServiceRoute.renderError);
  }
}

/// The route of one service. Checks the request, then runs a [GrpcCall].
class GrpcServiceRoute {
  GrpcServiceRoute(this.service, this.options);

  final Service service;
  final GrpcOptions options;

  /// Completes when the call ended. The call sends the answer itself.
  Future<void> handle(DoxRequest req) {
    HttpRequest raw = req.httpRequest;
    if (!isGrpcType(raw.headers.value(HttpHeaders.contentTypeHeader))) {
      throw HttpStatusException(
        HttpStatus.unsupportedMediaType,
        message: 'content-type must be application/grpc',
      );
    }
    req.takeOverResponse();
    NativeGrpcStream stream = NativeGrpcStream(raw);
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
      debug: showErrors(),
    );
    return call.run();
  }

  /// `application/grpc` or `application/grpc+proto`, with any parameters
  static bool isGrpcType(String? value) {
    if (value == null) return false;
    String type = value.split(';').first.trim().toLowerCase();
    return type == 'application/grpc' || type == 'application/grpc+proto';
  }

  /// A gRPC call: a `POST` with a gRPC content type. The fallback answers
  /// only these.
  static bool isGrpcRequest(HttpRequest req) {
    return req.method == 'POST' &&
        isGrpcType(req.headers.value(HttpHeaders.contentTypeHeader));
  }

  /// The fallback for a gRPC call to a service that is not registered.
  static DoxResponse unknownService(DoxRequest req) {
    return trailersOnly(
      GrpcException(
        GrpcStatus.unimplemented,
        'Service not found: ${req.httpRequest.uri.path}',
      ),
    );
  }

  /// An error before the call started (a middleware, or a body that
  /// fails) as a gRPC error. A request that is not gRPC at all keeps the
  /// normal Dox answer.
  static DoxResponse? renderError(Object error, DoxRequest req) {
    HttpRequest raw = req.httpRequest;
    if (!isGrpcType(raw.headers.value(HttpHeaders.contentTypeHeader))) {
      return null;
    }
    return trailersOnly(toGrpcException(error, debug: showErrors()));
  }

  /// [error] as a gRPC status. An HTTP error gets the gRPC status of its
  /// HTTP code, and keeps its message. Any other error is `INTERNAL`, with
  /// its text only when [debug] is true.
  static GrpcException toGrpcException(Object error, {required bool debug}) {
    if (error is GrpcException) return error;
    if (error is GrpcError) {
      return GrpcException(
        GrpcStatus.fromCode(error.code),
        error.message,
        error.details ?? const <GeneratedMessage>[],
      );
    }
    if (error is IHttpException) {
      Object? message = error.message;
      return GrpcException(
        GrpcStatus.fromHttp(error.code),
        message is String ? message : null,
      );
    }
    return GrpcException(
      GrpcStatus.internal,
      debug ? '$error' : 'Internal error',
    );
  }

  /// A trailers-only answer: HTTP 200 with the gRPC status in the headers
  /// and no body.
  static DoxResponse trailersOnly(GrpcException error) {
    DoxResponse res = DoxResponse(null)
        .statusCode(HttpStatus.ok)
        .header(HttpHeaders.contentTypeHeader, 'application/grpc')
        .header('grpc-accept-encoding', 'identity,gzip')
        .header('grpc-status', '${error.status.code}');
    String? message = error.message;
    if (message != null && message.isNotEmpty) {
      res.header('grpc-message', GrpcWire.percentEncode(message));
    }
    return res;
  }
}
