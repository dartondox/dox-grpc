import 'dart:math';

import 'package:dox_core/dox_core.dart';
import 'package:dox_core/router/route_data.dart';
import 'package:dox_grpc/dox_grpc.dart';
import 'package:dox_grpc/src/grpc.dart';
import 'package:test/test.dart';

import 'generated/echo.pbgrpc.dart';

class Echo extends EchoServiceBase {
  @override
  Future<EchoReply> unary(ServiceCall call, EchoRequest request) async {
    return EchoReply(text: request.text);
  }

  @override
  Stream<EchoReply> serverStream(ServiceCall call, EchoRequest request) {
    return const Stream<EchoReply>.empty();
  }

  @override
  Future<EchoReply> clientStream(
    ServiceCall call,
    Stream<EchoRequest> request,
  ) async {
    return EchoReply();
  }

  @override
  Stream<EchoReply> bidi(ServiceCall call, Stream<EchoRequest> request) {
    return const Stream<EchoReply>.empty();
  }
}

class Guard implements IDoxMiddleware {
  @override
  dynamic handle(IDoxRequest req) => req;
}

/// a router with no prefix, and with its own middleware
class GrpcRouter extends Router {
  @override
  List<dynamic> get middleware => <dynamic>[Guard()];

  @override
  void register() {
    Grpc.register(Echo());
  }
}

class PrefixedRouter extends Router {
  @override
  String get prefix => 'api';

  @override
  void register() {
    Grpc.register(Echo());
  }
}

String randomKey() {
  Random random = Random.secure();
  return String.fromCharCodes(
    List<int>.generate(32, (int _) => 0x61 + random.nextInt(26)),
  );
}

int grpcFallbacks() {
  return Route().fallbacks
      .where((RouteData r) => r.fallbackWhen == GrpcServiceRoute.isGrpcRequest)
      .length;
}

void main() {
  void clear() {
    Route().setRoutes(<RouteData>[]);
    Route().setFallbacks(<RouteData>[]);
    Route.prefix('');
    Route.resetWithNewMiddleware(<dynamic>[]);
  }

  setUp(() {
    clear();
    Dox().initialize(AppConfig(appKey: randomKey(), serverPort: 0));
  });

  tearDown(clear);

  Matcher noPrefixError = throwsA(
    isA<StateError>().having(
      (StateError e) => e.message,
      'message',
      allOf(contains('no prefix'), contains('dox.test.Echo')),
    ),
  );

  test('a service at the top gets its route and the fallback', () {
    Grpc.register(Echo());
    expect(Route().routes.last.path, '/dox.test.Echo/{method}');
    expect(grpcFallbacks(), 1);
  });

  test('a second service does not add a second fallback', () {
    Grpc.register(Echo());
    Grpc.register(Echo());
    expect(grpcFallbacks(), 1);
  });

  test('inside Route.group it throws', () {
    expect(
      () => Route.group('api', () => Grpc.register(Echo())),
      noPrefixError,
    );
  });

  test('after Route.prefix it throws', () {
    Route.prefix('v1');
    expect(() => Grpc.register(Echo()), noPrefixError);
  });

  test('a router with a prefix throws', () {
    Dox().initialize(
      AppConfig(
        appKey: randomKey(),
        serverPort: 0,
        routers: <Router>[PrefixedRouter()],
      ),
    );
    expect(() => Dox().loadRoutes(), noPrefixError);
  });

  test('the first register inside Route.middleware throws', () {
    expect(
      () => Route.middleware(<dynamic>[Guard()], () {
        Grpc.register(Echo());
      }),
      throwsA(
        isA<StateError>().having(
          (StateError e) => e.message,
          'message',
          contains('outside Route.middleware'),
        ),
      ),
    );
  });

  test('a later register inside Route.middleware is fine', () {
    Grpc.register(HealthService());
    Route.middleware(<dynamic>[Guard()], () {
      Grpc.register(Echo());
    });
    expect(grpcFallbacks(), 1);
    // the fallback has no group middleware
    RouteData fallback = Route().fallbacks.single;
    expect(fallback.preMiddleware, isEmpty);
  });

  test('a router with middleware is fine, loadRoutes can run again', () {
    Dox().initialize(
      AppConfig(
        appKey: randomKey(),
        serverPort: 0,
        routers: <Router>[GrpcRouter()],
      ),
    );
    for (int i = 0; i < 3; i++) {
      AppRoutes routes = Dox().loadRoutes();
      expect(
        routes.fallbacks
            .where(
              (RouteData r) => r.fallbackWhen == GrpcServiceRoute.isGrpcRequest,
            )
            .length,
        1,
        reason: 'run $i',
      );
      expect(
        routes.routes.map((RouteData r) => r.path),
        contains('/dox.test.Echo/{method}'),
      );
    }
  });
}
