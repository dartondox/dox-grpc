import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/dox_grpc.dart';
import 'package:dox_grpc/src/generated/grpc/health/v1/health.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:test/test.dart';

import 'generated/echo.pbgrpc.dart';
import 'raw_client.dart';

/// what the server saw, for the deadline and cancel tests
class Seen {
  Completer<bool> timedOut = Completer<bool>();
  Completer<bool> canceled = Completer<bool>();

  /// how many times the unary method ran
  int unaryRuns = 0;

  /// how the client stream method ended: its answer text, or the error
  /// that its request stream gave
  Completer<Object?> upload = Completer<Object?>();

  /// how the request stream of bidi ended: 'done', or its error
  Completer<Object?> bidiEnded = Completer<Object?>();

  /// the server stream method ended: the value of `call.isCanceled`
  Completer<bool> streamClosed = Completer<bool>();

  /// the messages the server stream method made so far
  int produced = 0;
}

class SpyHealth extends HealthService {
  /// completes when a Watch call ended
  Completer<void> watchClosed = Completer<void>();

  @override
  Stream<HealthCheckResponse> watch(
    ServiceCall call,
    HealthCheckRequest request,
  ) {
    StreamSubscription<HealthCheckResponse>? inner;
    StreamController<HealthCheckResponse> out =
        StreamController<HealthCheckResponse>();
    out.onListen = () {
      inner = super
          .watch(call, request)
          .listen(out.add, onError: out.addError, onDone: out.close);
    };
    out.onCancel = () async {
      await inner?.cancel();
      if (!watchClosed.isCompleted) watchClosed.complete();
    };
    return out.stream;
  }
}

class EchoService extends EchoServiceBase {
  EchoService(this.seen);

  final Seen seen;

  @override
  Future<EchoReply> unary(ServiceCall call, EchoRequest request) async {
    seen.unaryRuns++;
    String? input = call.clientMetadata!['x-in'];
    if (input != null) call.headers!['x-echo'] = input;
    String? bin = call.clientMetadata!['x-in-bin'];
    if (bin != null) call.trailers!['x-out-bin'] = bin;
    if (request.delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: request.delayMs));
      if (!seen.timedOut.isCompleted) seen.timedOut.complete(call.isTimedOut);
    }
    switch (request.text) {
      case 'fail':
        throw GrpcException(GrpcStatus.notFound, 'no ü 100%\n', <EchoReply>[
          EchoReply(text: 'detail'),
        ]);
      case 'grpc-error':
        throw const GrpcError.permissionDenied('nope');
      case 'crash':
        throw StateError('a secret');
      case 'status':
        call.sendTrailers(status: GrpcStatus.aborted.code, message: 'stop');
        return EchoReply();
      case 'late-throw':
        // the call is over, then the method fails
        call.sendTrailers(status: GrpcStatus.dataLoss.code, message: 'first');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        throw StateError('late');
    }
    return EchoReply(text: request.text, payload: request.payload);
  }

  @override
  Stream<EchoReply> serverStream(ServiceCall call, EchoRequest request) async* {
    try {
      for (int i = 0; i < request.count; i++) {
        if (call.isCanceled) {
          if (!seen.canceled.isCompleted) seen.canceled.complete(true);
          return;
        }
        seen.produced = i + 1;
        yield EchoReply(text: '${request.text}$i', payload: request.payload);
        if (request.delayMs > 0) {
          await Future<void>.delayed(Duration(milliseconds: request.delayMs));
        }
      }
    } finally {
      if (!seen.streamClosed.isCompleted) {
        seen.streamClosed.complete(call.isCanceled);
      }
    }
  }

  @override
  Future<EchoReply> clientStream(
    ServiceCall call,
    Stream<EchoRequest> request,
  ) async {
    StringBuffer text = StringBuffer();
    int bytes = 0;
    try {
      await for (EchoRequest r in request) {
        text.write(r.text);
        bytes += r.payload.length;
      }
    } catch (error) {
      if (!seen.upload.isCompleted) seen.upload.complete(error);
      rethrow;
    }
    if (!seen.upload.isCompleted) seen.upload.complete('$text:$bytes');
    return EchoReply(text: '$text:$bytes');
  }

  @override
  Stream<EchoReply> bidi(ServiceCall call, Stream<EchoRequest> request) async* {
    try {
      await for (EchoRequest r in request) {
        yield EchoReply(text: r.text.toUpperCase());
      }
    } catch (error) {
      if (!seen.bidiEnded.isCompleted) seen.bidiEnded.complete(error);
      rethrow;
    }
    if (!seen.bidiEnded.isCompleted) seen.bidiEnded.complete('done');
  }
}

/// a service behind a middleware that wants an `authorization` header
class GuardedEcho extends EchoService {
  GuardedEcho(super.seen);

  @override
  String get $name => 'dox.test.GuardedEcho';
}

/// a service whose calls end after a quiet time
class IdleEcho extends EchoService {
  IdleEcho(super.seen);

  @override
  String get $name => 'dox.test.IdleEcho';
}

class NeedsToken implements IDoxMiddleware {
  @override
  dynamic handle(IDoxRequest req) {
    if (req.header('authorization') != 'Bearer ok') {
      throw HttpStatusException(HttpStatus.unauthorized, message: 'no token');
    }
    return req;
  }
}

/// keeps the reported errors, so a test can check them
class RecordingHandler extends ExceptionHandler {
  final List<Object> reported = <Object>[];

  @override
  void report(Object error, StackTrace stackTrace) => reported.add(error);
}

final RecordingHandler errors = RecordingHandler();

String randomKey() {
  Random random = Random.secure();
  return String.fromCharCodes(
    List<int>.generate(32, (int _) => 0x61 + random.nextInt(26)),
  );
}

void main() {
  late Seen seen;
  late Seen idleSeen;
  late SpyHealth health;
  late ClientChannel channel;
  late EchoClient echo;

  setUpAll(() async {
    seen = Seen();
    idleSeen = Seen();
    health = SpyHealth();
    Grpc.register(
      EchoService(seen),
      options: const GrpcOptions(gzipResponses: true),
    );
    Grpc.register(health);
    Grpc.register(
      IdleEcho(idleSeen),
      options: const GrpcOptions(idleTimeout: Duration(milliseconds: 400)),
    );
    Route.middleware(<dynamic>[NeedsToken()], () {
      Grpc.register(GuardedEcho(seen));
    });
    Dox().initialize(
      AppConfig(
        appKey: randomKey(),
        serverPort: 0,
        totalIsolate: 1,
        http2: true,
        exceptionHandler: errors,
        // gRPC routes skip it, so the slow stream below is not cut
        globalMiddleware: <dynamic>[
          const RequestTimeout(Duration(milliseconds: 300)),
        ],
      ),
    );
    await Dox().startServer();
    channel = ClientChannel(
      '127.0.0.1',
      port: Dox().server.httpServer.port,
      options: ChannelOptions(
        credentials: const ChannelCredentials.insecure(),
        codecRegistry: CodecRegistry(
          codecs: const <Codec>[GzipCodec(), IdentityCodec()],
        ),
      ),
    );
    echo = EchoClient(channel);
  });

  tearDownAll(() async {
    await channel.shutdown();
    await Dox().server.close();
  });

  Matcher grpcCode(int code) =>
      isA<GrpcError>().having((GrpcError e) => e.code, 'code', code);

  test('unary', () async {
    EchoReply reply = await echo.unary(EchoRequest(text: 'hi'));
    expect(reply.text, 'hi');
  });

  test('unary with metadata: headers, trailers and -bin', () async {
    String bin = GrpcWire.encodeBinary(<int>[0xab, 0xab, 0xab]);
    ResponseFuture<EchoReply> call = echo.unary(
      EchoRequest(text: 'meta'),
      options: CallOptions(
        metadata: <String, String>{'x-in': 'hello', 'x-in-bin': bin},
      ),
    );
    expect((await call).text, 'meta');
    expect((await call.headers)['x-echo'], 'hello');
    expect((await call.trailers)['x-out-bin'], bin);
  });

  test('a big unary message (3 MiB) both ways', () async {
    Uint8List big = Uint8List(3 * 1024 * 1024);
    for (int i = 0; i < big.length; i++) {
      big[i] = i & 0xff;
    }
    EchoReply reply = await echo.unary(EchoRequest(text: 'big', payload: big));
    expect(reply.payload, big);
  });

  test('a request over 4 MiB is RESOURCE_EXHAUSTED', () async {
    await expectLater(
      echo.unary(EchoRequest(payload: Uint8List(5 * 1024 * 1024))),
      throwsA(grpcCode(StatusCode.resourceExhausted)),
    );
  });

  test('gzip request and gzip response', () async {
    ResponseFuture<EchoReply> call = echo.unary(
      EchoRequest(text: 'zip ' * 1000),
      options: CallOptions(compression: const GzipCodec()),
    );
    expect((await call).text, 'zip ' * 1000);
    expect((await call.headers)['grpc-encoding'], 'gzip');
  });

  test('server streaming', () async {
    List<EchoReply> replies = await echo
        .serverStream(EchoRequest(text: 'n', count: 100))
        .toList();
    expect(replies.map((EchoReply r) => r.text), <String>[
      for (int i = 0; i < 100; i++) 'n$i',
    ]);
  });

  test('a stream longer than RequestTimeout is not cut', () async {
    List<EchoReply> replies = await echo
        .serverStream(EchoRequest(text: 's', count: 10, delayMs: 60))
        .toList();
    expect(replies, hasLength(10));
  });

  test('a slow client holds the server stream back (backpressure)', () async {
    seen.produced = 0;
    seen.streamClosed = Completer<bool>();
    // a client that does not read: its flow control window fills up
    RawCall call = await RawCall.open(
      Dox().server.httpServer.port,
      '/dox.test.Echo/ServerStream',
    );
    call.pauseReading();
    call.send(
      rawFrame(
        EchoRequest(
          text: 'b',
          count: 30,
          payload: Uint8List(128 * 1024),
        ).writeToBuffer(),
      ),
      end: true,
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    // 30 messages were asked. A server that does not wait for the client
    // would have made all of them by now.
    int whileSlow = seen.produced;
    expect(whileSlow, lessThan(15));
    expect(seen.streamClosed.isCompleted, isFalse);
    // the client reads again: the rest comes
    call.resumeReading();
    RawResult res = await call.finish(timeout: const Duration(seconds: 20));
    await call.close();
    expect(res.status, 0);
    expect(res.messages, hasLength(30));
    expect(seen.produced, 30);
  });

  test('client streaming', () async {
    Stream<EchoRequest> requests = Stream<EchoRequest>.fromIterable(
      <EchoRequest>[
        for (int i = 0; i < 50; i++)
          EchoRequest(text: '$i', payload: Uint8List(100 * 1024)),
      ],
    );
    EchoReply reply = await echo.clientStream(requests);
    expect(
      reply.text,
      '${List<int>.generate(50, (int i) => i).join()}:'
      '${50 * 100 * 1024}',
    );
  });

  test('client streaming with no message', () async {
    EchoReply reply = await echo.clientStream(
      const Stream<EchoRequest>.empty(),
    );
    expect(reply.text, ':0');
  });

  test('bidi ping-pong', () async {
    StreamController<EchoRequest> out = StreamController<EchoRequest>();
    StreamIterator<EchoReply> replies = StreamIterator<EchoReply>(
      echo.bidi(out.stream),
    );
    for (String word in <String>['one', 'two', 'three']) {
      out.add(EchoRequest(text: word));
      expect(await replies.moveNext(), isTrue);
      expect(replies.current.text, word.toUpperCase());
    }
    await out.close();
    expect(await replies.moveNext(), isFalse);
  });

  test('GrpcException: status, encoded message and details', () async {
    try {
      await echo.unary(EchoRequest(text: 'fail'));
      fail('no error');
    } on GrpcError catch (e) {
      expect(e.code, StatusCode.notFound);
      expect(e.message, 'no ü 100%\n');
      expect(e.details, hasLength(1));
    }
  });

  test('GrpcError from package:grpc keeps its code', () async {
    await expectLater(
      echo.unary(EchoRequest(text: 'grpc-error')),
      throwsA(grpcCode(StatusCode.permissionDenied)),
    );
  });

  test('another error is INTERNAL, the text is hidden', () async {
    try {
      await echo.unary(EchoRequest(text: 'crash'));
      fail('no error');
    } on GrpcError catch (e) {
      expect(e.code, StatusCode.internal);
      expect(e.message, isNot(contains('secret')));
    }
    expect(errors.reported.whereType<StateError>(), hasLength(1));
    expect(errors.reported.whereType<GrpcError>(), isEmpty);
    expect(errors.reported.whereType<GrpcException>(), isEmpty);
  });

  test('sendTrailers with a status', () async {
    await expectLater(
      echo.unary(EchoRequest(text: 'status')),
      throwsA(grpcCode(StatusCode.aborted)),
    );
  });

  Future<void> callPath(String path, Matcher error) async {
    ClientMethod<EchoRequest, EchoReply> method =
        ClientMethod<EchoRequest, EchoReply>(
          path,
          (EchoRequest r) => r.writeToBuffer(),
          EchoReply.fromBuffer,
        );
    ClientCall<EchoRequest, EchoReply> call = channel.createCall(
      method,
      Stream<EchoRequest>.value(EchoRequest()),
      CallOptions(),
    );
    await expectLater(call.response.toList(), throwsA(error));
  }

  test('an unknown method is UNIMPLEMENTED', () async {
    await callPath('/dox.test.Echo/Nope', grpcCode(StatusCode.unimplemented));
  });

  test('an unknown service is UNIMPLEMENTED', () async {
    await callPath(
      '/dox.test.Missing/Unary',
      grpcCode(StatusCode.unimplemented),
    );
  });

  test('deadline: DEADLINE_EXCEEDED, the server sees isTimedOut', () async {
    // isTimedOut is true only when the timer of the call ran
    seen.timedOut = Completer<bool>();
    await expectLater(
      echo.unary(
        EchoRequest(text: 'slow', delayMs: 500),
        options: CallOptions(timeout: const Duration(milliseconds: 100)),
      ),
      throwsA(grpcCode(StatusCode.deadlineExceeded)),
    );
    expect(
      await seen.timedOut.future.timeout(const Duration(seconds: 5)),
      isTrue,
    );
  });

  test('deadline: a client stream that never ends gets an error', () async {
    seen.upload = Completer<Object?>();
    // a raw client does not cancel at the deadline itself, so the timer of
    // the server is the one that ends the call
    RawCall call = await RawCall.open(
      Dox().server.httpServer.port,
      '/dox.test.Echo/ClientStream',
      headers: <String, String>{'grpc-timeout': '200m'},
    );
    call.send(rawFrame(EchoRequest(text: 'a').writeToBuffer()));
    RawResult res = await call.finish();
    await call.close();
    expect(res.status, StatusCode.deadlineExceeded);
    Object? outcome = await seen.upload.future.timeout(
      const Duration(seconds: 5),
    );
    expect(outcome, isA<GrpcException>());
    expect((outcome! as GrpcException).status, GrpcStatus.deadlineExceeded);
  });

  test('cancel: the server sees isCanceled, its streams close', () async {
    seen.canceled = Completer<bool>();
    seen.streamClosed = Completer<bool>();
    ResponseStream<EchoReply> call = echo.serverStream(
      EchoRequest(text: 'c', count: 1000, delayMs: 20),
    );
    StreamIterator<EchoReply> it = StreamIterator<EchoReply>(call);
    expect(await it.moveNext(), isTrue);
    await call.cancel();
    expect(
      await seen.canceled.future.timeout(const Duration(seconds: 5)),
      isTrue,
    );
    expect(
      await seen.streamClosed.future.timeout(const Duration(seconds: 5)),
      isTrue,
    );
  });

  test('cancel: the request stream of the method ends with an error', () async {
    seen.bidiEnded = Completer<Object?>();
    StreamController<EchoRequest> out = StreamController<EchoRequest>();
    ResponseStream<EchoReply> call = echo.bidi(out.stream);
    StreamIterator<EchoReply> it = StreamIterator<EchoReply>(call);
    out.add(EchoRequest(text: 'x'));
    expect(await it.moveNext(), isTrue);
    await call.cancel();
    Object? outcome = await seen.bidiEnded.future.timeout(
      const Duration(seconds: 5),
    );
    expect(outcome, grpcCode(StatusCode.cancelled));
    await out.close();
  });

  test('cancel: a Watch stream closes', () async {
    health.watchClosed = Completer<void>();
    HealthClient client = HealthClient(channel);
    ResponseStream<HealthCheckResponse> call = client.watch(
      HealthCheckRequest(service: 'dox.test.Cancelled'),
    );
    StreamIterator<HealthCheckResponse> it =
        StreamIterator<HealthCheckResponse>(call);
    expect(await it.moveNext(), isTrue);
    await call.cancel();
    await health.watchClosed.future.timeout(const Duration(seconds: 5));
  });

  test('middleware runs before the handler', () async {
    GuardedEchoClient guarded = GuardedEchoClient(channel);
    await expectLater(
      guarded.unary(EchoRequest(text: 'x')),
      throwsA(
        isA<GrpcError>()
            .having((GrpcError e) => e.code, 'code', StatusCode.unauthenticated)
            .having((GrpcError e) => e.message, 'message', 'no token'),
      ),
    );
    EchoReply ok = await guarded.unary(
      EchoRequest(text: 'x'),
      options: CallOptions(
        metadata: <String, String>{'authorization': 'Bearer ok'},
      ),
    );
    expect(ok.text, 'x');
  });

  test('HTTP/1.1 and a wrong content type get plain HTTP errors', () async {
    HttpClient client = HttpClient();
    int port = Dox().server.httpServer.port;
    HttpClientRequest req = await client.post(
      '127.0.0.1',
      port,
      '/dox.test.Echo/Unary',
    );
    req.headers.contentType = ContentType.parse('application/json');
    req.write('{}');
    HttpClientResponse res = await req.close();
    expect(res.statusCode, HttpStatus.unsupportedMediaType);
    await res.drain<void>();

    req = await client.post('127.0.0.1', port, '/dox.test.Echo/Unary');
    req.headers.contentType = ContentType.parse('application/grpc');
    req.add(GrpcWire.frame(EchoRequest(text: 'h1').writeToBuffer()));
    res = await req.close();
    expect(res.statusCode, HttpStatus.httpVersionNotSupported);
    expect(await res.transform(utf8.decoder).join(), contains('HTTP/2'));
    client.close();
  });

  group('a bad request', () {
    int port() => Dox().server.httpServer.port;
    Uint8List request([String text = 'raw']) =>
        EchoRequest(text: text).writeToBuffer();

    /// sends [body] to [path], ends the request, gives the answer
    Future<RawResult> post(
      String path,
      List<int> body, {
      String? te = 'trailers',
      Map<String, String> headers = const <String, String>{},
    }) async {
      RawCall call = await RawCall.open(port(), path, te: te, headers: headers);
      call.send(body, end: true);
      RawResult result = await call.finish();
      await call.close();
      return result;
    }

    List<int> two(List<int> a, List<int> b) => <int>[...a, ...b];

    test('a missing te header is fine', () async {
      RawResult res = await post(
        '/dox.test.Echo/Unary',
        rawFrame(request()),
        te: null,
      );
      expect(res.status, 0);
      expect(EchoReply.fromBuffer(res.messages.single).text, 'raw');
    });

    // The native server resets `te: Trailers` (capital T) itself, so a
    // case-insensitive te can not reach the call. Only `trailers` can.
    test('te: trailers works, any other te is INTERNAL', () async {
      RawResult ok = await post('/dox.test.Echo/Unary', rawFrame(request()));
      expect(ok.status, 0);
      // the native server may reset it before the call starts
      RawResult bad = await post(
        '/dox.test.Echo/Unary',
        rawFrame(request()),
        te: 'gzip',
      );
      expect(bad.reset || bad.status == StatusCode.internal, isTrue);
    });

    test('a bad grpc-timeout is INTERNAL', () async {
      int runs = seen.unaryRuns;
      RawResult res = await post(
        '/dox.test.Echo/Unary',
        rawFrame(request()),
        headers: <String, String>{'grpc-timeout': 'soon'},
      );
      expect(res.status, StatusCode.internal);
      expect(res.message, contains('grpc-timeout'));
      expect(seen.unaryRuns, runs);
    });

    test('a compressed flag that is not 0 or 1 is INTERNAL', () async {
      RawResult res = await post(
        '/dox.test.Echo/Unary',
        rawFrame(request(), flag: 2),
      );
      expect(res.status, StatusCode.internal);
      expect(res.message, contains('flag'));
    });

    test('a compressed message with no grpc-encoding is INTERNAL', () async {
      RawResult res = await post(
        '/dox.test.Echo/Unary',
        rawFrame(request(), flag: 1),
      );
      expect(res.status, StatusCode.internal);
    });

    test('a gzip bomb is RESOURCE_EXHAUSTED, the server stays up', () async {
      // 8 MiB of zeros in a few KiB
      List<int> bomb = gzip.encode(Uint8List(8 * 1024 * 1024));
      expect(bomb.length, lessThan(64 * 1024));
      int runs = seen.unaryRuns;
      RawResult res = await post(
        '/dox.test.Echo/Unary',
        rawFrame(bomb, flag: 1),
        headers: <String, String>{'grpc-encoding': 'gzip'},
      );
      expect(res.status, StatusCode.resourceExhausted);
      expect(seen.unaryRuns, runs);
      expect((await echo.unary(EchoRequest(text: 'up'))).text, 'up');
    });

    test('many zipped messages in one part are all read, in order', () async {
      Uint8List payload = Uint8List(100 * 1024);
      List<int> zipped = gzip.encode(
        EchoRequest(text: 'z', payload: payload).writeToBuffer(),
      );
      BytesBuilder body = BytesBuilder();
      for (int i = 0; i < 100; i++) {
        body.add(rawFrame(zipped, flag: 1));
      }
      seen.upload = Completer<Object?>();
      RawResult res = await post(
        '/dox.test.Echo/ClientStream',
        body.takeBytes(),
        headers: <String, String>{'grpc-encoding': 'gzip'},
      );
      expect(res.status, 0);
      expect(
        EchoReply.fromBuffer(res.messages.single).text,
        '${'z' * 100}:${100 * payload.length}',
      );
    });

    test('a message that is not a protobuf is INTERNAL', () async {
      int runs = seen.unaryRuns;
      RawResult res = await post(
        '/dox.test.Echo/Unary',
        rawFrame(<int>[0xff, 0xff, 0xff, 0xff, 0xff]),
      );
      expect(res.status, StatusCode.internal);
      expect(seen.unaryRuns, runs);
    });

    test('a unary call with 2 messages never runs the method', () async {
      int runs = seen.unaryRuns;
      RawResult res = await post(
        '/dox.test.Echo/Unary',
        two(rawFrame(request('one')), rawFrame(request('two'))),
      );
      expect(res.status, isNot(0));
      expect(res.messages, isEmpty);
      expect(seen.unaryRuns, runs);
    });

    test('a unary call with 0 messages is an error', () async {
      int runs = seen.unaryRuns;
      RawResult res = await post('/dox.test.Echo/Unary', <int>[]);
      expect(res.status, StatusCode.unimplemented);
      expect(seen.unaryRuns, runs);
    });

    test('a unary call with a half message is an error', () async {
      int runs = seen.unaryRuns;
      Uint8List whole = rawFrame(request());
      RawResult res = await post(
        '/dox.test.Echo/Unary',
        whole.sublist(0, whole.length - 2),
      );
      expect(res.status, StatusCode.internal);
      expect(seen.unaryRuns, runs);
    });

    test('an upload with a bad message gives the method an error', () async {
      seen.upload = Completer<Object?>();
      RawResult res = await post(
        '/dox.test.Echo/ClientStream',
        two(rawFrame(request('a')), rawFrame(request('b'), flag: 7)),
      );
      expect(res.status, StatusCode.internal);
      Object? outcome = await seen.upload.future.timeout(
        const Duration(seconds: 5),
      );
      expect(outcome, isA<GrpcException>());
    });

    test('an upload with a message over the limit gives an error', () async {
      seen.upload = Completer<Object?>();
      RawCall call = await RawCall.open(port(), '/dox.test.Echo/ClientStream');
      call.send(rawFrame(request('a')));
      // only the head of a 5 MiB message is needed
      Uint8List head = Uint8List(5);
      ByteData.sublistView(head).setUint32(1, 5 * 1024 * 1024);
      call.send(head);
      RawResult res = await call.finish();
      await call.close();
      expect(res.status, StatusCode.resourceExhausted);
      Object? outcome = await seen.upload.future.timeout(
        const Duration(seconds: 5),
      );
      expect(outcome, isA<GrpcException>());
    });

    test('an upload with a half last message is not a whole upload', () async {
      seen.upload = Completer<Object?>();
      Uint8List whole = rawFrame(request('b'));
      RawResult res = await post(
        '/dox.test.Echo/ClientStream',
        two(rawFrame(request('a')), whole.sublist(0, whole.length - 1)),
      );
      expect(res.status, StatusCode.internal);
      Object? outcome = await seen.upload.future.timeout(
        const Duration(seconds: 5),
      );
      expect(outcome, isA<GrpcException>());
    });

    test('a client reset in the middle of an upload', () async {
      seen.upload = Completer<Object?>();
      RawCall call = await RawCall.open(port(), '/dox.test.Echo/ClientStream');
      call.send(rawFrame(request('a')));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      call.reset();
      Object? outcome = await seen.upload.future.timeout(
        const Duration(seconds: 5),
      );
      expect(outcome, grpcCode(StatusCode.cancelled));
      await call.close();
    });

    test('a method that fails after the call ended', () async {
      seen.upload = Completer<Object?>();
      RawResult res = await post(
        '/dox.test.Echo/Unary',
        rawFrame(request('late-throw')),
      );
      // the first end wins
      expect(res.status, StatusCode.dataLoss);
      expect(res.message, 'first');
      // wait for the late error, then check that the server is fine
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect((await echo.unary(EchoRequest(text: 'up'))).text, 'up');
    });
  });

  group('idle timeout', () {
    int port() => Dox().server.httpServer.port;

    test('a unary call that never ends is cut', () async {
      RawCall call = await RawCall.open(port(), '/dox.test.IdleEcho/Unary');
      call.send(rawFrame(EchoRequest(text: 'x').writeToBuffer()));
      Stopwatch watch = Stopwatch()..start();
      RawResult res = await call.finish();
      await call.close();
      expect(res.status, StatusCode.deadlineExceeded);
      expect(res.message, contains('idle'));
      expect(watch.elapsed, greaterThan(const Duration(milliseconds: 300)));
      expect(watch.elapsed, lessThan(const Duration(seconds: 3)));
    });

    test('a client that never reads does not hold the call', () async {
      RawCall call = await RawCall.open(
        port(),
        '/dox.test.IdleEcho/ServerStream',
      );
      call.send(
        rawFrame(
          EchoRequest(
            text: 's',
            count: 100,
            payload: Uint8List(1024 * 1024),
          ).writeToBuffer(),
        ),
        end: true,
      );
      call.pauseReading();
      expect(
        await idleSeen.streamClosed.future.timeout(const Duration(seconds: 5)),
        isTrue,
      );
      expect(idleSeen.produced, lessThan(100));
      call.reset();
      await call.close();
    });

    test('a call that keeps talking is not cut', () async {
      IdleEchoClient client = IdleEchoClient(channel);
      List<EchoReply> replies = await client
          .serverStream(EchoRequest(text: 'k', count: 8, delayMs: 150))
          .toList();
      expect(replies, hasLength(8));
    });
  });

  test('50 streams at the same time', () async {
    List<Future<Object?>> calls = <Future<Object?>>[
      for (int i = 0; i < 25; i++) echo.unary(EchoRequest(text: 'u$i')),
      for (int i = 0; i < 25; i++)
        echo.serverStream(EchoRequest(text: 's$i', count: 20)).toList(),
    ];
    List<Object?> results = await Future.wait(calls);
    for (int i = 0; i < 25; i++) {
      expect((results[i]! as EchoReply).text, 'u$i');
      List<EchoReply> stream = results[25 + i]! as List<EchoReply>;
      expect(stream, hasLength(20));
      expect(stream.last.text, 's${i}19');
    }
  });

  group('health', () {
    late HealthClient client;
    setUp(() => client = HealthClient(channel));

    test('Check', () async {
      HealthCheckResponse all = await client.check(HealthCheckRequest());
      expect(all.status, ServingStatus.SERVING);
      await expectLater(
        client.check(HealthCheckRequest(service: 'nope')),
        throwsA(grpcCode(StatusCode.notFound)),
      );
      health.setStatus('dox.test.Echo', ServingStatus.NOT_SERVING);
      HealthCheckResponse one = await client.check(
        HealthCheckRequest(service: 'dox.test.Echo'),
      );
      expect(one.status, ServingStatus.NOT_SERVING);
    });

    test('Watch', () async {
      ResponseStream<HealthCheckResponse> call = client.watch(
        HealthCheckRequest(service: 'dox.test.Watched'),
      );
      StreamIterator<HealthCheckResponse> it =
          StreamIterator<HealthCheckResponse>(call);
      expect(await it.moveNext(), isTrue);
      expect(it.current.status, ServingStatus.SERVICE_UNKNOWN);
      health.setStatus('dox.test.Watched', ServingStatus.SERVING);
      expect(await it.moveNext(), isTrue);
      expect(it.current.status, ServingStatus.SERVING);
      await call.cancel();
    });
  });
}

/// a client for [GuardedEcho]: the same methods, another service name
class GuardedEchoClient extends Client {
  GuardedEchoClient(super.channel);

  static final ClientMethod<EchoRequest, EchoReply> _unary =
      ClientMethod<EchoRequest, EchoReply>(
        '/dox.test.GuardedEcho/Unary',
        (EchoRequest r) => r.writeToBuffer(),
        EchoReply.fromBuffer,
      );

  ResponseFuture<EchoReply> unary(EchoRequest request, {CallOptions? options}) {
    return $createUnaryCall(_unary, request, options: options);
  }
}

/// a client for [IdleEcho]
class IdleEchoClient extends Client {
  IdleEchoClient(super.channel);

  static final ClientMethod<EchoRequest, EchoReply> _serverStream =
      ClientMethod<EchoRequest, EchoReply>(
        '/dox.test.IdleEcho/ServerStream',
        (EchoRequest r) => r.writeToBuffer(),
        EchoReply.fromBuffer,
      );

  ResponseStream<EchoReply> serverStream(EchoRequest request) {
    return $createStreamingCall(
      _serverStream,
      Stream<EchoRequest>.value(request),
    );
  }
}
