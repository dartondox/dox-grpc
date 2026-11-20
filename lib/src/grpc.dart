import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_core/router/route_data.dart';
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

  /// Adds the route `POST /<package.Service>/{method}` for [service]. A
  /// method the service does not have gets `UNIMPLEMENTED`. So does a
  /// gRPC call to a service that is not registered.
  ///
  /// The route skips `RequestTimeout`, so a long stream is not cut. Its
  /// errors (eg. a middleware that throws 401) go to the client as gRPC
  /// errors.
  ///
  /// Throws a [StateError] when a prefix or group changed the route path,
  /// because no gRPC client could reach it then.
  static void register(
    Service service, {
    GrpcOptions options = const GrpcOptions(),
  }) {
    GrpcServiceRoute route = GrpcServiceRoute(service, options);
    String path = '/${service.$name}/{method}';
    Route.post(path, route.handle)
        .withoutMiddleware<RequestTimeout>()
        .renderErrorsWith(GrpcServiceRoute.renderError);
    _checkPath(Route().routes.last.path, path);
    if (Route().fallbacks.any(_isOurFallback)) return;
    Route.fallback(
      GrpcServiceRoute.unknownService,
      when: GrpcServiceRoute.isGrpcRequest,
    ).renderErrorsWith(GrpcServiceRoute.renderError);
    RouteData fallback = Route().fallbacks.last;
    _checkPath(fallback.path, '/');
    if (!_hasOnlyRouterMiddleware(fallback.preMiddleware)) {
      throw StateError(
        'dox_grpc: the first Grpc.register is inside Route.middleware. The '
        'fallback for unknown services would run that middleware too. '
        'Register the first service (eg. the HealthService) in a router '
        'with no prefix, outside Route.middleware.',
      );
    }
  }

  static bool _isOurFallback(RouteData data) {
    return data.fallbackWhen == GrpcServiceRoute.isGrpcRequest;
  }

  /// Throws when [actual] is not [expected], ignoring `//` and an end `/`.
  static void _checkPath(String actual, String expected) {
    if (_clean(actual) == _clean(expected)) return;
    throw StateError(
      'dox_grpc: the route is "$actual", but gRPC clients call '
      '"$expected". Register gRPC services in a router with no prefix, '
      'outside any Route.group or Route.prefix.',
    );
  }

  static String _clean(String path) {
    String clean = path.replaceAll(RegExp('/+'), '/');
    if (clean.length > 1 && clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    return clean.isEmpty ? '/' : clean;
  }

  /// true when [middleware] is only what a router gets: the global
  /// middleware, then the middleware of one router. Any more came from a
  /// `Route.middleware` around the call.
  static bool _hasOnlyRouterMiddleware(List<dynamic> middleware) {
    if (middleware.isEmpty) return true;
    List<dynamic> global = Dox().allGlobalMiddleware;
    List<Router> routers = <Router>[
      ...Dox().config.routers,
      ...Dox().ioc.routers,
    ];
    if (_sameItems(middleware, global)) return true;
    for (Router router in routers) {
      if (_sameItems(middleware, <dynamic>[...global, ...router.middleware])) {
        return true;
      }
    }
    return false;
  }

  /// Same kinds, in order. A router makes its middleware list again on each
  /// call, so the objects themselves can not be compared.
  ///
  /// Known limit: the kinds are all we have. `RouteData` does not say which
  /// router a list came from. So a `Route.middleware([Auth], ...)` in a
  /// router A is not seen when another router B has `[Auth]` as its own
  /// middleware: both lists look the same.
  static bool _sameItems(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].runtimeType != b[i].runtimeType) return false;
    }
    return true;
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
  /// HTTP code, and keeps its message, but a 5xx keeps it only when [debug]
  /// is true. Any other error is `INTERNAL`, with its text only when
  /// [debug] is true.
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
      // the text of a 5xx may show inner details: only in debug
      if (error.code >= 500 && !debug) {
        return GrpcException(GrpcStatus.fromHttp(error.code), 'Internal error');
      }
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
