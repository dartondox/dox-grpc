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

/// what the server saw, for the deadline and cancel tests
class Seen {
  Completer<bool> timedOut = Completer<bool>();
  Completer<bool> canceled = Completer<bool>();
}

class EchoService extends EchoServiceBase {
  EchoService(this.seen);

  final Seen seen;

  @override
  Future<EchoReply> unary(ServiceCall call, EchoRequest request) async {
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
    }
    return EchoReply(text: request.text, payload: request.payload);
  }

  @override
  Stream<EchoReply> serverStream(ServiceCall call, EchoRequest request) async* {
    for (int i = 0; i < request.count; i++) {
      if (call.isCanceled) {
        if (!seen.canceled.isCompleted) seen.canceled.complete(true);
        return;
      }
      yield EchoReply(text: '${request.text}$i', payload: request.payload);
      if (request.delayMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: request.delayMs));
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
    await for (EchoRequest r in request) {
      text.write(r.text);
      bytes += r.payload.length;
    }
    return EchoReply(text: '$text:$bytes');
  }

  @override
  Stream<EchoReply> bidi(ServiceCall call, Stream<EchoRequest> request) async* {
    await for (EchoRequest r in request) {
      yield EchoReply(text: r.text.toUpperCase());
    }
  }
}

/// a service behind a middleware that wants an `authorization` header
class GuardedEcho extends EchoService {
  GuardedEcho(super.seen);

  @override
  String get $name => 'dox.test.GuardedEcho';
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
  late HealthService health;
  late ClientChannel channel;
  late EchoClient echo;

  setUpAll(() async {
    seen = Seen();
    health = HealthService();
    Grpc.register(
      EchoService(seen),
      options: const GrpcOptions(gzipResponses: true),
    );
    Grpc.register(health);
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

  test('server streaming of 20 MiB (backpressure)', () async {
    Uint8List payload = Uint8List(1024 * 1024);
    int count = 0;
    await for (EchoReply r in echo.serverStream(
      EchoRequest(text: 'b', count: 20, payload: payload),
    )) {
      expect(r.payload.length, payload.length);
      count++;
    }
    expect(count, 20);
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

  test('cancel: the server sees isCanceled', () async {
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
