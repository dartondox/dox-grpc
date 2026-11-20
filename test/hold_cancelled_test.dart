import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/src/grpc_call.dart';
import 'package:dox_grpc/src/grpc_options.dart';
import 'package:dox_grpc/src/native_stream.dart';
import 'package:dox_grpc/src/wire.dart';
import 'package:grpc/service_api.dart';
import 'package:test/test.dart';

import 'generated/echo.pbgrpc.dart';

/// A cancelled call must end its answer only after the handler really
/// ended. The native server counts a call until its answer ends, so a
/// client that resets calls fast can not pile up handler work in Dart.

/// what happened, in order
final List<String> events = <String>[];

/// The native stream, without a server. It logs the end of the answer.
class FakeStream implements NativeGrpcStream {
  FakeStream([Map<String, String> headers = const <String, String>{}])
    : requestHeaders = FakeHeaders(headers);

  final StreamController<Uint8List> input = StreamController<Uint8List>();
  final Completer<void> goneSignal = Completer<void>();
  final Map<String, String> sent = <String, String>{};

  @override
  final HttpHeaders requestHeaders;

  @override
  bool get isHttp2 => true;

  @override
  InternetAddress? get remoteAddress => null;

  @override
  Stream<Uint8List> get body => input.stream;

  @override
  Future<void> get gone => goneSignal.future;

  @override
  bool get headSent => false;

  @override
  void setHeader(String name, String value) => sent[name] = value;

  @override
  void setTrailer(String name, String value) => sent[name] = value;

  @override
  void start(int status) {}

  @override
  void add(List<int> bytes) => events.add('message');

  @override
  Future<void> flush() => Future<void>.value();

  @override
  void end() => events.add('end');

  @override
  void reject(int status, String text) {}
}

class FakeHeaders implements HttpHeaders {
  FakeHeaders(this._values);

  final Map<String, String> _values;

  @override
  String? value(String name) => _values[name];

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach(
      (String name, String value) => action(name, <String>[value]),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRequest implements HttpRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SlowEcho extends EchoServiceBase {
  /// completes when a handler started
  Completer<void> started = Completer<void>();

  /// lets the unary handler finish
  Completer<void> release = Completer<void>();

  @override
  Future<EchoReply> unary(ServiceCall call, EchoRequest request) async {
    started.complete();
    await release.future;
    events.add('handler done');
    return EchoReply(text: request.text);
  }

  @override
  Stream<EchoReply> serverStream(ServiceCall call, EchoRequest request) async* {
    try {
      yield EchoReply(text: 'first');
      started.complete();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield EchoReply(text: 'never sent');
    } finally {
      events.add('handler done');
    }
  }

  @override
  Future<EchoReply> clientStream(
    ServiceCall call,
    Stream<EchoRequest> request,
  ) => throw UnimplementedError();

  @override
  Stream<EchoReply> bidi(ServiceCall call, Stream<EchoRequest> request) =>
      throw UnimplementedError();
}

/// Starts [method] with one request message. The body is closed.
Future<void> start(SlowEcho service, FakeStream stream, String method) {
  GrpcCall call = GrpcCall(
    stream,
    service,
    service.$lookupMethod(method),
    const GrpcOptions(),
    errors: ExceptionHandler(),
    request: FakeRequest(),
    debug: true,
  );
  Future<void> finished = call.run();
  stream.input
    ..add(GrpcWire.frame(EchoRequest(text: 'hi').writeToBuffer()))
    ..close();
  return finished;
}

/// lets timers and microtasks run
Future<void> settle([int ms = 20]) {
  return Future<void>.delayed(Duration(milliseconds: ms));
}

void main() {
  setUp(events.clear);

  test('a cancelled unary call ends after its handler', () async {
    SlowEcho service = SlowEcho();
    FakeStream stream = FakeStream();
    Future<void> finished = start(service, stream, 'Unary');
    await service.started.future;

    stream.goneSignal.complete();
    await settle();
    expect(events, isEmpty, reason: 'the handler still runs');

    service.release.complete();
    await finished;
    expect(events, <String>['handler done', 'end']);
    expect(stream.sent['grpc-status'], isNull, reason: 'no status to nobody');
  });

  test('a cancelled async* stream ends after the generator exits', () async {
    SlowEcho service = SlowEcho();
    FakeStream stream = FakeStream();
    Future<void> finished = start(service, stream, 'ServerStream');
    await service.started.future;

    stream.goneSignal.complete();
    await settle();
    // the generator waits on its delay; the answer is still open
    expect(events, <String>['message']);

    await finished;
    expect(events, <String>['message', 'handler done', 'end']);
  });

  test('a call past its deadline sends the status after its handler', () async {
    SlowEcho service = SlowEcho();
    FakeStream stream = FakeStream(<String, String>{'grpc-timeout': '20m'});
    Future<void> finished = start(service, stream, 'Unary');
    await service.started.future;

    await settle(60);
    expect(events, isEmpty, reason: 'the handler still runs');

    service.release.complete();
    await finished;
    expect(events, <String>['handler done', 'end']);
    expect(stream.sent['grpc-status'], '4');
  });

  test('a call that ends normally is unchanged', () async {
    SlowEcho service = SlowEcho();
    FakeStream stream = FakeStream();
    Future<void> finished = start(service, stream, 'Unary');
    service.release.complete();
    await finished;
    expect(events, <String>['handler done', 'message', 'end']);
    expect(stream.sent['grpc-status'], '0');
  });
}
