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
  }) : _reader = GrpcMessageReader(_options.maxReceiveMessageSize);

  final NativeGrpcStream _stream;
  final Service _service;

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
  bool _received = false;

  /// the one message of a call with a single request. It goes to the
  /// handler only when the client is done, so a call with a bad second
  /// message never runs the handler.
  dynamic _single;

  /// frames that wait their turn, see [_onPart]
  final Queue<GrpcFrame> _queued = Queue<GrpcFrame>();

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
    StreamController<dynamic> requests = _requests = method.createRequestStream(
      incoming,
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

  /// One part of the body. Messages that need unzip, when there are many
  /// in this part, are done one per event loop turn (see [_drain]). So a
  /// small zipped part with hundreds of messages can not hold the isolate.
  /// The usual part (no zip, or one message) is done at once.
  void _onPart(Uint8List part) {
    if (_ended) return;
    _touch();
    List<GrpcFrame> frames;
    try {
      frames = _reader.add(part);
    } on GrpcException catch (error) {
      _failRequest(error);
      return;
    }
    if (frames.length > 1 && frames.any(_isCompressed)) {
      _queued.addAll(frames);
      _drain();
      return;
    }
    for (GrpcFrame frame in frames) {
      if (!_handleFrame(frame)) return;
    }
  }

  static bool _isCompressed(GrpcFrame frame) => frame.compressed;

  /// Handles the queued frames, and waits one event loop turn after each.
  /// The body is paused meanwhile, so no part comes in between.
  Future<void> _drain() async {
    StreamSubscription<Uint8List> incoming = _incoming!;
    incoming.pause();
    while (_queued.isNotEmpty && !_ended) {
      if (!_handleFrame(_queued.removeFirst())) break;
      await Future<void>.delayed(Duration.zero);
    }
    _queued.clear();
    if (!_ended) incoming.resume();
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
    if (!_headWritten) _writeHead();
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

  void _onMethodDone() => _endWith(GrpcException(GrpcStatus.ok));

  void _onMethodError(Object error, StackTrace stackTrace) {
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

  void _setCustomHeader(String name, String value) {
    String lower = name.toLowerCase();
    if (lower.startsWith(':') || lower == 'content-type') return;
    _stream.setHeader(lower, value);
  }

  void _setCustomTrailer(String name, String value) {
    String lower = name.toLowerCase();
    if (lower.startsWith(':') || lower == 'content-type') return;
    _stream.setTrailer(lower, value);
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
    if (_headWritten) {
      trailers.forEach(_setCustomTrailer);
    } else {
      _writeHead();
      trailers.forEach(_setCustomHeader);
    }
    _stream.end();
    _stopAll();
    _finished.complete();
  }

  /// The client left or reset the stream: stop, send nothing.
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
    _stream.end();
    _stopAll();
    _finished.complete();
  }

  void _stopAll() {
    StreamController<dynamic>? requests = _requests;
    if (requests != null && !requests.isClosed) requests.close();
    _incoming?.cancel();
    _responses?.cancel();
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
