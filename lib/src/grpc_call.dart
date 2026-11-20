import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/src/generated/google/rpc/status.pb.dart' as rpc;
import 'package:dox_grpc/src/grpc.dart';
import 'package:dox_grpc/src/grpc_options.dart';
import 'package:dox_grpc/src/grpc_status.dart';
import 'package:dox_grpc/src/native_stream.dart';
import 'package:dox_grpc/src/wire.dart';
import 'package:grpc/grpc.dart' show GrpcError, ServerInterceptor;
import 'package:grpc/service_api.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';

/// One gRPC call: reads the request messages, runs the service method,
/// and writes the answer with its status in the trailers.
class GrpcCall implements ServiceCall {
  GrpcCall(
    this._stream,
    this._service,
    this._method,
    this._options, {
    required this._errors,
    required this._request,
    required this._debug,
    this._holdLimit = defaultHoldLimit,
  }) : _reader = GrpcMessageReader(_options.maxReceiveMessageSize);

  /// How long a status waits for a handler that does not end, after the
  /// deadline or the idle timeout fired. It is the same as `ZOMBIE_WAIT` in
  /// `dox_http_native`: after this time the native server stops counting
  /// the call. Without it, a client that stays connected would wait for
  /// ever for a handler that hangs.
  static const Duration defaultHoldLimit = Duration(seconds: 30);

  final NativeGrpcStream _stream;
  final Service _service;
  final Duration _holdLimit;

  /// null when the service has no such method
  final ServiceMethod<dynamic, dynamic>? _method;
  final GrpcOptions _options;
  final ExceptionHandler _errors;
  final HttpRequest _request;

  /// show the text of unknown errors to the client
  final bool _debug;
  final GrpcMessageReader _reader;

  /// completes when the call ended (sent, failed or cancelled)
  final Completer<void> _finished = Completer<void>();

  final Map<String, String> _clientMetadata = <String, String>{};
  Map<String, String>? _headers = <String, String>{};
  Map<String, String>? _trailers = <String, String>{};

  DateTime? _deadline;
  Timer? _timer;
  Timer? _idleTimer;
  bool _timedOut = false;
  bool _canceled = false;

  /// true once the call has its end (a status, or the client left)
  bool _ended = false;

  /// true once the response headers are set on the response
  bool _headWritten = false;

  /// true once the handler ended (its answer stream is done or failed)
  bool _handlerDone = false;

  /// the status that waits to go out, see [_finish]
  Map<String, String>? _status;

  /// ends the wait for the handler when it takes too long, see [_holdLimit]
  Timer? _holdTimer;

  /// true once [_finish] ran. It runs only once.
  bool _finishRan = false;

  /// completes when a single answer that is still on its way ends, see
  /// [_stopAll]
  Completer<void>? _lateAnswer;
  bool _received = false;

  /// the one message of a call with a single request. It goes to the
  /// handler only when the client is done, so a call with a bad second
  /// message never runs the handler.
  dynamic _single;

  /// frames that wait their turn, see [_pump]
  final Queue<GrpcFrame> _queued = Queue<GrpcFrame>();

  /// true while [_incoming] is held paused because of [_queued]
  bool _holding = false;

  /// true while a pump waits for the next event loop turn
  bool _turnPending = false;

  /// the `grpc-encoding` of the request, lower case
  String? _requestEncoding;
  bool _gzipResponses = false;

  StreamSubscription<Uint8List>? _incoming;
  StreamController<dynamic>? _requests;
  StreamSubscription<dynamic>? _responses;

  @override
  Map<String, String> get clientMetadata => _clientMetadata;

  @override
  Map<String, String>? get headers => _headers;

  @override
  Map<String, String>? get trailers => _trailers;

  @override
  DateTime? get deadline => _deadline;

  /// true once the deadline passed (our timer ran, or the client cancelled
  /// at its deadline before our timer did)
  @override
  bool get isTimedOut => _timedOut;

  @override
  bool get isCanceled => _canceled;

  @override
  X509Certificate? get clientCertificate => null;

  @override
  InternetAddress? get remoteAddress => _stream.remoteAddress;

  /// Runs the call. Completes when it ended.
  Future<void> run() {
    HttpHeaders requestHeaders = _stream.requestHeaders;
    requestHeaders.forEach(_addMetadata);
    _requestEncoding = requestHeaders.value('grpc-encoding')?.toLowerCase();
    _gzipResponses =
        _options.gzipResponses &&
        (requestHeaders.value('grpc-accept-encoding') ?? '')
            .toLowerCase()
            .split(',')
            .map(_trim)
            .contains('gzip');

    ServiceMethod<dynamic, dynamic>? method = _method;
    // a missing `te` is fine. When it is there, it must be `trailers`.
    String? te = requestHeaders.value('te');
    if (te != null && te.toLowerCase() != 'trailers') {
      _endWith(
        GrpcException(GrpcStatus.internal, 'The te header must be trailers'),
      );
      return _finished.future;
    }
    if (method == null) {
      _endWith(
        GrpcException(
          GrpcStatus.unimplemented,
          'Method not found: ${_request.uri.path}',
        ),
      );
      return _finished.future;
    }

    String? rawTimeout = requestHeaders.value('grpc-timeout');
    Duration? timeout = GrpcWire.parseTimeout(rawTimeout);
    if (rawTimeout != null && timeout == null) {
      _endWith(
        GrpcException(GrpcStatus.internal, 'Malformed grpc-timeout header'),
      );
      return _finished.future;
    }

    _stream.gone.then(_onGone);
    if (timeout != null) {
      _deadline = DateTime.now().add(timeout);
      _timer = Timer(timeout, _onTimeout);
    }

    _touch();
    StreamSubscription<Uint8List> incoming = _incoming = _stream.body.listen(
      _onPart,
      onError: _onBodyError,
      onDone: _onBodyDone,
    );
    // read only when the method listens to its requests
    incoming.pause();
    // the gate tells us when the handler reads again, see [_pump]
    StreamController<dynamic> requests = _requests = method.createRequestStream(
      _RequestGate(incoming, this),
    );

    try {
      _service.$onMetadata(this);
    } catch (error, stackTrace) {
      _endWith(_toException(error, stackTrace));
      return _finished.future;
    }
    if (_ended) return _finished.future;

    _responses = method
        .handle(this, requests.stream, const <ServerInterceptor>[])
        .listen(
          _onMessage,
          onError: _onMethodError,
          onDone: _onMethodDone,
          cancelOnError: true,
        );
    return _finished.future;
  }

  @override
  void sendHeaders() {
    if (_headWritten) throw GrpcError.internal('Headers already sent');
    _writeHead();
    _stream.flush().ignore();
  }

  @override
  void sendTrailers({int? status, String? message}) {
    GrpcStatus code = GrpcStatus.fromCode(status ?? 0);
    _endWith(GrpcException(code, message));
  }

  // ---- the request ----

  void _addMetadata(String name, List<String> values) {
    if (name.startsWith(':') ||
        name.startsWith('grpc-') ||
        name == 'content-type' ||
        name == 'te') {
      return;
    }
    _clientMetadata[name] = values.join(',');
  }

  /// One part of the body. The frames go to [_queued] and [_pump] hands
  /// them over. The usual part (one message) is done at once.
  void _onPart(Uint8List part) {
    if (_ended) return;
    _touch();
    try {
      _queued.addAll(_reader.add(part));
    } on GrpcException catch (error) {
      _failRequest(error);
      return;
    }
    _pump();
  }

  /// Hands the queued frames to the handler, while it reads. When the
  /// handler pauses its request stream, the rest waits here and the body is
  /// held, so one big part with many small messages can not fill the memory
  /// of a slow handler. A zipped message is done one per event loop turn,
  /// so a small zipped part with hundreds of messages can not hold the
  /// isolate. The usual part (one message) needs no wait.
  void _pump() {
    if (_turnPending) return;
    ServiceMethod<dynamic, dynamic> method = _method!;
    while (_queued.isNotEmpty && !_ended) {
      if (method.streamingRequest && _requests!.isPaused) break;
      GrpcFrame frame = _queued.removeFirst();
      if (!_handleFrame(frame)) return;
      if (_queued.isEmpty || !method.streamingRequest) continue;
      // The request stream gives its events later. Wait for that, so a
      // handler that pauses on the first message is seen before the next
      // one. A zipped message waits a whole event loop turn.
      _turnPending = true;
      if (frame.compressed) {
        Future<void>.delayed(Duration.zero, _nextTurn);
      } else {
        scheduleMicrotask(_nextTurn);
      }
      break;
    }
    if (_ended) return;
    if (_queued.isNotEmpty && !_holding) {
      _holding = true;
      _incoming!.pause();
    } else if (_queued.isEmpty && _holding) {
      _holding = false;
      _incoming!.resume();
    }
  }

  void _nextTurn() {
    _turnPending = false;
    _pump();
  }

  /// the handler resumed its request stream. Later, so the controller is
  /// in its new state.
  void _onHandlerResume() {
    if (_queued.isNotEmpty) scheduleMicrotask(_pump);
  }

  /// false when the call ended because of this frame
  bool _handleFrame(GrpcFrame frame) {
    try {
      _onFrame(frame);
    } on GrpcException catch (error) {
      _failRequest(error);
      return false;
    }
    return !_ended;
  }

  void _onFrame(GrpcFrame frame) {
    ServiceMethod<dynamic, dynamic> method = _method!;
    if (_received && !method.streamingRequest) {
      throw GrpcException(GrpcStatus.unimplemented, 'Too many requests');
    }
    Uint8List data = frame.data;
    if (frame.compressed) {
      String? encoding = _requestEncoding;
      if (encoding == 'gzip') {
        data = GrpcWire.gzipDecode(data, _options.maxReceiveMessageSize);
      } else if (encoding == null || encoding == 'identity') {
        throw GrpcException(
          GrpcStatus.internal,
          'A compressed message, but no grpc-encoding',
        );
      } else {
        throw GrpcException(
          GrpcStatus.unimplemented,
          'Message compressed with $encoding, which is not supported',
        );
      }
    }
    dynamic message;
    try {
      message = method.deserialize(data);
    } catch (_) {
      throw GrpcException(
        GrpcStatus.internal,
        'Could not parse the request message',
      );
    }
    _received = true;
    if (method.streamingRequest) {
      _requests!.add(message);
    } else {
      _single = message;
    }
  }

  void _onBodyDone() {
    if (_ended) return;
    if (_reader.hasPartial) {
      _failRequest(
        GrpcException(GrpcStatus.internal, 'The last message is not whole'),
      );
    } else if (!_received && !_method!.streamingRequest) {
      _failRequest(
        GrpcException(GrpcStatus.unimplemented, 'No request received'),
      );
    } else {
      if (!_method!.streamingRequest) _requests!.add(_single);
      _requests!.close();
    }
  }

  /// The request side failed (a bad message, an early end). The handler
  /// gets the error in its request stream, so it can not take a half
  /// request as a whole one. Then the call ends with the same error.
  void _failRequest(GrpcException error) {
    StreamController<dynamic>? requests = _requests;
    if (requests != null && !requests.isClosed) requests.addError(error);
    _endWith(error);
  }

  /// the client reset the stream
  void _onBodyError(Object error) => _cancel();

  /// the client reset the stream or the connection died
  void _onGone(void _) => _cancel();

  void _onTimeout() {
    if (_ended) return;
    _timedOut = true;
    _canceled = true;
    _failRequest(
      GrpcException(GrpcStatus.deadlineExceeded, 'Deadline exceeded'),
    );
  }

  /// Restarts the idle timer. Called on each message in or out.
  void _touch() {
    Duration? idle = _options.idleTimeout;
    if (idle == null || _ended) return;
    _idleTimer?.cancel();
    _idleTimer = Timer(idle, _onIdle);
  }

  void _onIdle() {
    if (_ended) return;
    _canceled = true;
    _failRequest(
      GrpcException(
        GrpcStatus.deadlineExceeded,
        'No message for ${_options.idleTimeout!.inSeconds} s (idle timeout)',
      ),
    );
  }

  // ---- the answer ----

  void _onMessage(dynamic message) {
    if (_ended) return;
    ServiceMethod<dynamic, dynamic> method = _method!;
    List<int> bytes;
    try {
      bytes = method.serialize(message);
    } catch (error, stackTrace) {
      _endWith(_toException(error, stackTrace));
      return;
    }
    if (bytes.length > _options.maxSendMessageSize) {
      _endWith(
        GrpcException(
          GrpcStatus.resourceExhausted,
          'Sent message larger than max '
          '(${bytes.length} vs. ${_options.maxSendMessageSize})',
        ),
      );
      return;
    }
    if (_gzipResponses) bytes = GrpcWire.gzipEncode(bytes);
    if (!_headWritten) {
      try {
        _writeHead();
      } catch (error, stackTrace) {
        _endWith(_toException(error, stackTrace));
        return;
      }
    }
    _stream.add(GrpcWire.frame(bytes, compressed: _gzipResponses));
    _touch();
    if (!method.streamingResponse) return;
    // send it now, and wait while the client is slow
    StreamSubscription<dynamic> responses = _responses!;
    responses.pause();
    _stream.flush().then(_resume, onError: _resume);
  }

  void _resume(Object? _) {
    _touch();
    StreamSubscription<dynamic>? responses = _responses;
    if (responses != null && responses.isPaused) responses.resume();
  }

  void _onMethodDone() {
    _handlerDone = true;
    _endWith(GrpcException(GrpcStatus.ok));
  }

  void _onMethodError(Object error, StackTrace stackTrace) {
    _handlerDone = true;
    _endWith(_toException(error, stackTrace));
  }

  /// the status, headers and the default response headers
  void _writeHead() {
    _headWritten = true;
    _stream.start(HttpStatus.ok);
    _stream.setHeader(HttpHeaders.contentTypeHeader, 'application/grpc');
    _stream.setHeader('grpc-accept-encoding', 'identity,gzip');
    if (_gzipResponses) _stream.setHeader('grpc-encoding', 'gzip');
    _headers?.forEach(_setCustomHeader);
    _headers = null;
  }

  /// A header the native server refuses (eg. a value with a non-ASCII
  /// letter or a control char) is dropped and reported. The call goes on,
  /// and it still ends with its own status.
  void _setCustomHeader(String name, String value) {
    String lower = name.toLowerCase();
    if (lower.startsWith(':') || lower == 'content-type') return;
    try {
      _stream.setHeader(lower, value);
    } catch (error, stackTrace) {
      _reportBadMetadata('header', lower, error, stackTrace);
    }
  }

  /// like [_setCustomHeader], for a trailer
  void _setCustomTrailer(String name, String value) {
    String lower = name.toLowerCase();
    if (lower.startsWith(':') || lower == 'content-type') return;
    try {
      _stream.setTrailer(lower, value);
    } catch (error, stackTrace) {
      _reportBadMetadata('trailer', lower, error, stackTrace);
    }
  }

  void _reportBadMetadata(
    String kind,
    String name,
    Object error,
    StackTrace stackTrace,
  ) {
    _errors.reportFor(
      _request,
      StateError('dox_grpc: dropped the $kind "$name": $error'),
      stackTrace,
    );
  }

  /// Ends the call with [error] (or OK). Before any message this is a
  /// trailers-only answer: the status goes in the headers.
  void _endWith(GrpcException error, [Map<String, String>? extra]) {
    if (_ended) return;
    _ended = true;
    _timer?.cancel();
    _idleTimer?.cancel();

    Map<String, String> trailers = <String, String>{
      ...?_trailers,
      ...?extra,
      'grpc-status': '${error.status.code}',
    };
    _trailers = null;
    String? message = error.message;
    if (message != null && message.isNotEmpty) {
      trailers['grpc-message'] = GrpcWire.percentEncode(message);
    }
    if (error.details.isNotEmpty) {
      trailers['grpc-status-details-bin'] = _details(error);
    }
    _status = trailers;
    if (_canceled) {
      // past the deadline (or idle): the status waits for the handler, so
      // the native server counts the call until the handler really ended
      _endAfterHandler();
      return;
    }
    _finish(null);
    _stopAll();
  }

  /// Sends [_status] (when set) and ends the answer.
  void _finish(Object? _) {
    if (_finishRan) return;
    _finishRan = true;
    _holdTimer?.cancel();
    Map<String, String>? trailers = _status;
    _status = null;
    try {
      if (trailers == null) {
        // the client is gone: no status
      } else if (_headWritten) {
        trailers.forEach(_setCustomTrailer);
      } else {
        _writeHead();
        trailers.forEach(_setCustomHeader);
      }
    } catch (error, stackTrace) {
      try {
        _reportBadMetadata('status', 'grpc-status', error, stackTrace);
      } catch (_) {
        // the app's error reporter threw: the call must still end
      }
    } finally {
      // the call must always end, or the client waits for ever
      try {
        _stream.end();
      } catch (error, stackTrace) {
        try {
          _errors.reportFor(_request, error, stackTrace);
        } catch (_) {
          // the app's error reporter threw: the call must still end
        }
      }
      _finished.complete();
    }
  }

  /// Stops the handler, and ends the answer only once the handler really
  /// ended. A Dart handler can not be killed. The native server counts a
  /// call against `maxConcurrentStreams` until its answer ends, so a client
  /// that cancels calls fast can not pile up handler work. A handler that
  /// never ends: the native server stops counting it after 30 s.
  void _endAfterHandler() {
    Future<void>? running = _stopAll();
    if (running == null) {
      _finish(null);
      return;
    }
    // a status does not wait for ever for a handler that hangs
    if (_status != null) _holdTimer = Timer(_holdLimit, _finishNow);
    running.then(_finish, onError: _finish);
  }

  void _finishNow() => _finish(null);

  /// The client left or reset the stream: stop, send no status.
  void _cancel() {
    if (_ended) return;
    _ended = true;
    _canceled = true;
    DateTime? deadline = _deadline;
    if (deadline != null && !DateTime.now().isBefore(deadline)) {
      _timedOut = true;
    }
    _timer?.cancel();
    _idleTimer?.cancel();
    // the request stream is already closed when the client sent all its
    // messages before it left
    StreamController<dynamic>? requests = _requests;
    if (requests != null && !requests.isClosed) {
      requests.addError(GrpcError.cancelled('Cancelled'));
    }
    _status = null;
    _endAfterHandler();
  }

  /// Stops reading and stops the handler. Returns a Future that completes
  /// once the handler really ended, or null when it is not running.
  Future<void>? _stopAll() {
    StreamController<dynamic>? requests = _requests;
    if (requests != null && !requests.isClosed) requests.close();
    _queued.clear();
    _incoming?.cancel();
    StreamSubscription<dynamic>? responses = _responses;
    if (responses == null || _handlerDone) return null;
    if (_method!.streamingResponse) {
      // a stream stops here. The cancel of an async* method completes when
      // its body exited (after its await and its finally blocks). An error
      // of its cleanup comes with the cancel.
      return responses.cancel().then(_ignore, onError: _reportLate);
    }
    // a single answer is still on its way, maybe with an error. Keep
    // listening, so a late error is reported and not lost, and so we know
    // when the handler ended. A cancel would not wait for it.
    Completer<void> late = _lateAnswer = Completer<void>();
    responses
      ..onData(_ignore)
      ..onError(_onLateError)
      ..onDone(_onLateDone);
    return late.future;
  }

  static void _ignore(Object? _) {}

  /// An error of the handler after the call ended. The client has its
  /// status already, so the error is only reported.
  void _reportLate(Object error, StackTrace stackTrace) {
    try {
      _toException(error, stackTrace);
    } catch (_) {
      // the error handler itself failed: nobody is left to tell, and the
      // call must still end
    }
  }

  /// the single answer failed after the call ended (it is cancelled on
  /// error, so no done comes)
  void _onLateError(Object error, StackTrace stackTrace) {
    _reportLate(error, stackTrace);
    _onLateDone();
  }

  void _onLateDone() {
    _handlerDone = true;
    Completer<void>? late = _lateAnswer;
    _lateAnswer = null;
    late?.complete();
  }

  /// `google.rpc.Status` with the details, base64 for the `-bin` header
  static String _details(GrpcException error) {
    rpc.Status status = rpc.Status(
      code: error.status.code,
      message: error.message ?? '',
      details: error.details.map(_pack),
    );
    return GrpcWire.encodeBinary(status.writeToBuffer());
  }

  static Any _pack(GeneratedMessage message) => Any.pack(message);

  static String _trim(String text) => text.trim();

  /// Any error as a gRPC status. An error that is not a gRPC or HTTP error
  /// is INTERNAL. It is reported, and its text is hidden outside debug mode.
  GrpcException _toException(Object error, StackTrace stackTrace) {
    if (error is! GrpcException &&
        error is! GrpcError &&
        !(error is IHttpException && error.code < 500)) {
      _errors.reportFor(_request, error, stackTrace);
    }
    return GrpcServiceRoute.toGrpcException(error, debug: _debug);
  }
}

/// The body subscription, as the request stream of the method sees it. A
/// resume tells the call, so it can hand over the frames that waited.
class _RequestGate implements StreamSubscription<Uint8List> {
  _RequestGate(this._inner, this._call);

  final StreamSubscription<Uint8List> _inner;
  final GrpcCall _call;

  @override
  void pause([Future<void>? resumeSignal]) => _inner.pause(resumeSignal);

  @override
  void resume() {
    _inner.resume();
    _call._onHandlerResume();
  }

  @override
  bool get isPaused => _inner.isPaused;

  @override
  Future<void> cancel() => _inner.cancel();

  @override
  void onData(void Function(Uint8List data)? handleData) =>
      _inner.onData(handleData);

  @override
  void onError(Function? handleError) => _inner.onError(handleError);

  @override
  void onDone(void Function()? handleDone) => _inner.onDone(handleDone);

  @override
  Future<E> asFuture<E>([E? futureValue]) => _inner.asFuture(futureValue);
}
