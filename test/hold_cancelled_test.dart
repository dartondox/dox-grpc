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

  /// what [hasRoom] answers
  bool room = false;

  /// how many times the call flushed
  int flushes = 0;

  /// what a flush waits for (null: nothing)
  Completer<void>? flushWait;

  @override
  bool get hasRoom => room;

  @override
  Future<void> flush() {
    flushes++;
    return flushWait?.future ?? Future<void>.value();
  }

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

  /// lets the handler go on
  Completer<void> release = Completer<void>();

  /// the handler throws when it goes on
  bool fail = false;

  Future<void> _wait() async {
    started.complete();
    await release.future;
    if (fail) throw StateError('boom');
    events.add('handler done');
  }

  @override
  Future<EchoReply> unary(ServiceCall call, EchoRequest request) async {
    await _wait();
    return EchoReply(text: request.text);
  }

  @override
  Stream<EchoReply> serverStream(ServiceCall call, EchoRequest request) =>
      _stream();

  Stream<EchoReply> _stream() async* {
    try {
      yield EchoReply(text: 'first');
      await _wait();
      yield EchoReply(text: 'never sent');
    } finally {
      events.add('stream exit');
    }
  }

  @override
  Future<EchoReply> clientStream(
    ServiceCall call,
    Stream<EchoRequest> request,
  ) async {
    await _wait();
    return EchoReply(text: 'done');
  }

  @override
  Stream<EchoReply> bidi(ServiceCall call, Stream<EchoRequest> request) =>
      _stream();
}

/// A server stream of [count] messages, made one after the other.
class CountEcho extends SlowEcho {
  CountEcho(this.count);

  final int count;

  @override
  Stream<EchoReply> serverStream(ServiceCall call, EchoRequest request) async* {
    for (int i = 0; i < count; i++) {
      yield EchoReply(text: 'm$i');
    }
  }
}

/// Records the reports. [fail] makes the report itself throw.
class RecordingHandler extends ExceptionHandler {
  RecordingHandler({this.fail = false});

  final bool fail;
  final List<Object> reported = <Object>[];

  @override
  void reportFor(HttpRequest req, Object error, StackTrace stackTrace) {
    reported.add(error);
    if (fail) throw StateError('the report failed');
  }
}

/// Starts [method] with one request message. The body is closed.
Future<void> start(
  SlowEcho service,
  FakeStream stream,
  String method, {
  GrpcOptions options = const GrpcOptions(),
  Duration holdLimit = GrpcCall.defaultHoldLimit,
  ExceptionHandler? errors,
}) {
  GrpcCall call = GrpcCall(
    stream,
    service,
    service.$lookupMethod(method),
    options,
    errors: errors ?? ExceptionHandler(),
    request: FakeRequest(),
    debug: true,
    holdLimit: holdLimit,
  );
  Future<void> finished = call.run();
  stream.input
    ..add(GrpcWire.frame(EchoRequest(text: 'hi').writeToBuffer()))
    ..close();
  return finished;
}

int ends() => events.where((String e) => e == 'end').length;

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
    // the generator waits; the answer is still open
    expect(events, <String>['message']);

    service.release.complete();
    await finished;
    expect(events, <String>['message', 'handler done', 'stream exit', 'end']);
  });

  test('a cancelled client streaming call ends after its handler', () async {
    SlowEcho service = SlowEcho();
    FakeStream stream = FakeStream();
    Future<void> finished = start(service, stream, 'ClientStream');
    await service.started.future;

    stream.goneSignal.complete();
    await settle();
    expect(events, isEmpty, reason: 'the handler still runs');

    service.release.complete();
    await finished;
    expect(events, <String>['handler done', 'end']);
  });

  test('a cancelled bidi call ends after its handler', () async {
    SlowEcho service = SlowEcho();
    FakeStream stream = FakeStream();
    Future<void> finished = start(service, stream, 'Bidi');
    await service.started.future;

    stream.goneSignal.complete();
    await settle();
    expect(events, <String>['message']);

    service.release.complete();
    await finished;
    expect(events, <String>['message', 'handler done', 'stream exit', 'end']);
  });

  group('room in the native window', () {
    test('with room the handler is never paused', () async {
      FakeStream stream = FakeStream()..room = true;
      await start(CountEcho(50), stream, 'ServerStream');
      expect(stream.flushes, 0);
      expect(events.where((String e) => e == 'message'), hasLength(50));
      expect(events.last, 'end');
    });

    test('with no room each message waits for its flush', () async {
      FakeStream stream = FakeStream();
      await start(CountEcho(50), stream, 'ServerStream');
      expect(stream.flushes, 50);
      expect(events.where((String e) => e == 'message'), hasLength(50));
    });

    test('a full window holds the handler back until the flush ends', () async {
      FakeStream stream = FakeStream()..flushWait = Completer<void>();
      Future<void> finished = start(CountEcho(50), stream, 'ServerStream');
      await settle();
      expect(events, <String>['message'], reason: 'paused after the first');
      expect(stream.flushes, 1);

      stream.room = true; // Rust sent the data: there is room again
      stream.flushWait!.complete();
      await finished;
      expect(events.where((String e) => e == 'message'), hasLength(50));
      expect(stream.flushes, 1, reason: 'no pause while there is room');
    });
  });

  for (String method in <String>['Unary', 'ServerStream']) {
    test(
      '$method: a handler that throws after cancel ends the call once',
      () async {
        SlowEcho service = SlowEcho()..fail = true;
        FakeStream stream = FakeStream();
        RecordingHandler errors = RecordingHandler();
        Future<void> finished = start(service, stream, method, errors: errors);
        await service.started.future;

        stream.goneSignal.complete();
        await settle();
        service.release.complete();
        await finished;
        await settle();

        expect(ends(), 1);
        expect(errors.reported, hasLength(1));
        expect(errors.reported.single, isA<StateError>());
      },
    );

    test(
      '$method: an error handler that throws does not stop the end',
      () async {
        SlowEcho service = SlowEcho()..fail = true;
        FakeStream stream = FakeStream();
        RecordingHandler errors = RecordingHandler(fail: true);
        Future<void> finished = start(service, stream, method, errors: errors);
        await service.started.future;

        stream.goneSignal.complete();
        await settle();
        service.release.complete();
        await finished.timeout(const Duration(seconds: 5));
        await settle();

        expect(ends(), 1);
        expect(errors.reported, hasLength(1));
      },
    );
  }

  test('a call past its deadline sends the status after its handler', () async {
    SlowEcho service = SlowEcho();
    FakeStream stream = FakeStream(<String, String>{'grpc-timeout': '100m'});
    Future<void> finished = start(service, stream, 'Unary');
    await service.started.future;

    await settle(200);
    expect(events, isEmpty, reason: 'the handler still runs');

    service.release.complete();
    await finished;
    expect(events, <String>['handler done', 'end']);
    expect(stream.sent['grpc-status'], '4');
  });

  test(
    'a call past its idle timeout sends the status after its handler',
    () async {
      SlowEcho service = SlowEcho();
      FakeStream stream = FakeStream();
      Future<void> finished = start(
        service,
        stream,
        'Unary',
        options: const GrpcOptions(idleTimeout: Duration(milliseconds: 100)),
      );
      await service.started.future;

      await settle(200);
      expect(events, isEmpty, reason: 'the handler still runs');

      service.release.complete();
      await finished;
      expect(events, <String>['handler done', 'end']);
      expect(stream.sent['grpc-status'], '4');
    },
  );

  test('a cancel after the deadline still sends the status once', () async {
    SlowEcho service = SlowEcho();
    FakeStream stream = FakeStream(<String, String>{'grpc-timeout': '100m'});
    Future<void> finished = start(service, stream, 'Unary');
    await service.started.future;

    await settle(200);
    stream.goneSignal.complete();
    await settle();
    expect(events, isEmpty, reason: 'the handler still runs');

    service.release.complete();
    await finished;
    await settle();
    expect(events, <String>['handler done', 'end']);
    expect(stream.sent['grpc-status'], '4');
  });

  test('a handler that never ends does not hold the status for ever', () async {
    SlowEcho service = SlowEcho();
    FakeStream stream = FakeStream(<String, String>{'grpc-timeout': '100m'});
    Future<void> finished = start(
      service,
      stream,
      'Unary',
      holdLimit: const Duration(milliseconds: 50),
    );
    await service.started.future;

    // the handler is never released
    await finished.timeout(const Duration(seconds: 5));
    expect(events, <String>['end']);
    expect(stream.sent['grpc-status'], '4');

    // the handler ends later: the call does not end a second time
    service.release.complete();
    await settle();
    expect(ends(), 1);
  });

  test('a call that ends normally is unchanged', () async {
    SlowEcho service = SlowEcho();
    FakeStream stream = FakeStream();
    Future<void> finished = start(service, stream, 'Unary');
    await service.started.future;
    service.release.complete();
    await finished;
    expect(events, <String>['handler done', 'message', 'end']);
    expect(stream.sent['grpc-status'], '0');
  });
}
