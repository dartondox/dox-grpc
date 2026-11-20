// The gRPC interop test service (grpc.testing.TestService) on a Dox server.
// The interop clients of other gRPC languages (eg. grpc-go) call it. See
// ci/interop.sh.
//
//   dart run test/interop/server.dart --port 10000 --isolates 2

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/dox_grpc.dart';

import 'generated/src/proto/grpc/testing/empty.pb.dart';
import 'generated/src/proto/grpc/testing/messages.pb.dart';
import 'generated/src/proto/grpc/testing/test.pbgrpc.dart';

const String echoInitial = 'x-grpc-test-echo-initial';
const String echoTrailing = 'x-grpc-test-echo-trailing-bin';
const String testService = 'grpc.testing.TestService';

class TestService extends TestServiceBase {
  @override
  Future<Empty> emptyCall(ServiceCall call, Empty request) async => Empty();

  @override
  Future<SimpleResponse> unaryCall(
    ServiceCall call,
    SimpleRequest request,
  ) async {
    _echoMetadata(call);
    _throwStatus(request.responseStatus);
    return SimpleResponse(payload: _payload(request.responseSize));
  }

  @override
  Future<SimpleResponse> cacheableUnaryCall(
    ServiceCall call,
    SimpleRequest request,
  ) {
    return unaryCall(call, request);
  }

  @override
  Stream<StreamingOutputCallResponse> streamingOutputCall(
    ServiceCall call,
    StreamingOutputCallRequest request,
  ) async* {
    _echoMetadata(call);
    for (ResponseParameters params in request.responseParameters) {
      await _sleep(params.intervalUs);
      yield StreamingOutputCallResponse(payload: _payload(params.size));
    }
    _throwStatus(request.responseStatus);
  }

  @override
  Future<StreamingInputCallResponse> streamingInputCall(
    ServiceCall call,
    Stream<StreamingInputCallRequest> request,
  ) async {
    int total = 0;
    await for (StreamingInputCallRequest message in request) {
      total += message.payload.body.length;
    }
    return StreamingInputCallResponse(aggregatedPayloadSize: total);
  }

  @override
  Stream<StreamingOutputCallResponse> fullDuplexCall(
    ServiceCall call,
    Stream<StreamingOutputCallRequest> request,
  ) async* {
    _echoMetadata(call);
    await for (StreamingOutputCallRequest message in request) {
      _throwStatus(message.responseStatus);
      for (ResponseParameters params in message.responseParameters) {
        await _sleep(params.intervalUs);
        yield StreamingOutputCallResponse(payload: _payload(params.size));
      }
    }
  }

  @override
  Stream<StreamingOutputCallResponse> halfDuplexCall(
    ServiceCall call,
    Stream<StreamingOutputCallRequest> request,
  ) async* {
    List<StreamingOutputCallRequest> all = await request.toList();
    _echoMetadata(call);
    for (StreamingOutputCallRequest message in all) {
      for (ResponseParameters params in message.responseParameters) {
        await _sleep(params.intervalUs);
        yield StreamingOutputCallResponse(payload: _payload(params.size));
      }
      _throwStatus(message.responseStatus);
    }
  }

  @override
  Future<Empty> unimplementedCall(ServiceCall call, Empty request) {
    throw GrpcException(GrpcStatus.unimplemented);
  }

  static void _echoMetadata(ServiceCall call) {
    String? initial = call.clientMetadata![echoInitial];
    if (initial != null) call.headers![echoInitial] = initial;
    String? trailing = call.clientMetadata![echoTrailing];
    if (trailing != null) call.trailers![echoTrailing] = trailing;
  }

  static void _throwStatus(EchoStatus status) {
    if (status.code == 0) return;
    throw GrpcException(GrpcStatus.fromCode(status.code), status.message);
  }

  static Payload _payload(int size) {
    return Payload(type: PayloadType.COMPRESSABLE, body: Uint8List(size));
  }

  static Future<void> _sleep(int micros) {
    if (micros <= 0) return Future<void>.value();
    return Future<void>.delayed(Duration(microseconds: micros));
  }
}

/// Changes the health status of the TestService. A change in one isolate
/// must reach the others; ci/interop.sh checks that with 2 isolates.
class XdsUpdateHealthService extends XdsUpdateHealthServiceBase {
  XdsUpdateHealthService(this.health);

  final HealthService health;

  @override
  Future<Empty> setServing(ServiceCall call, Empty request) async {
    health.setStatus(testService, ServingStatus.SERVING);
    return Empty();
  }

  @override
  Future<Empty> setNotServing(ServiceCall call, Empty request) async {
    health.setStatus(testService, ServingStatus.NOT_SERVING);
    return Empty();
  }

  @override
  Future<HookResponse> sendHookRequest(ServiceCall call, HookRequest request) {
    throw GrpcException(GrpcStatus.unimplemented);
  }
}

/// The id of this isolate. A top-level final is one value per isolate.
final String isolateId = Random().nextInt(1 << 30).toString();

/// A health service that tells which isolate answered. Test only.
class InteropHealthService extends HealthService {
  @override
  Future<HealthCheckResponse> check(
    ServiceCall call,
    HealthCheckRequest request,
  ) {
    call.headers!['x-dox-isolate'] = isolateId;
    return super.check(call, request);
  }
}

class InteropRouter extends Router {
  @override
  void register() {
    HealthService health = InteropHealthService();
    Grpc.register(health);
    Grpc.register(TestService());
    Grpc.register(XdsUpdateHealthService(health));
    health.setStatus(testService, ServingStatus.SERVING);
  }
}

Future<void> main(List<String> args) async {
  int port = int.parse(_arg(args, '--port') ?? '10000');
  int isolates = int.parse(_arg(args, '--isolates') ?? '1');
  Dox().initialize(
    AppConfig(
      appKey: 'interop-test-key-not-a-secret-00',
      serverPort: port,
      totalIsolate: isolates,
      http2: true,
      routers: <Router>[InteropRouter()],
    ),
  );
  await Dox().startServer();
  print('interop server on port $port, $isolates isolate(s)');
}

String? _arg(List<String> args, String name) {
  int i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
}
