import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dox_http_native/dox_http_native.dart';

/// The only place that uses the native server API. Everything else in
/// dox_grpc talks to this class, so a change in dox_http_native is fixed
/// here.
///
/// The native server gives an HTTP/2 request with `content-type:
/// application/grpc*` as a stream of body parts ([NativeRequest.isStreamed]).
/// A request that ends on its HEADERS is a normal request with an empty
/// body. Both are read the same way: listen to the request.
class NativeGrpcStream {
  NativeGrpcStream(HttpRequest request)
    : _request = request as NativeRequest,
      _response = request.response;

  final NativeRequest _request;
  final NativeResponse _response;

  /// true when the client used HTTP/2. gRPC needs it for the trailers.
  bool get isHttp2 => _request.protocolVersion == '2.0';

  /// the request headers. Names are lower case.
  HttpHeaders get requestHeaders => _request.headers;

  /// the address of the client, when known
  InternetAddress? get remoteAddress => _request.connectionInfo.remoteAddress;

  /// The request body in parts. Pause the subscription to hold the client
  /// back (the native server acks a part only after the listener took it).
  /// A client reset ends it with an [HttpException].
  Stream<Uint8List> get body => _request;

  /// Completes once, when the client is gone (it reset the stream or the
  /// connection died) before the answer was sent. Never completes for an
  /// answer that ends normally.
  Future<void> get gone => _response.gone;

  /// true once the status and the headers went out
  bool get headSent => _response.headSent;

  void setHeader(String name, String value) {
    _response.headers.set(name, value);
  }

  void setTrailer(String name, String value) {
    _response.trailers.set(name, value);
  }

  /// Starts the answer with [status] and the headers set so far.
  void start(int status) {
    _response.statusCode = status;
    // the server presets text/plain, gRPC sets its own type
    _response.headers.removeAll(HttpHeaders.contentLengthHeader);
  }

  /// Adds body bytes. They go out on [flush] or at the end.
  void add(List<int> bytes) => _response.add(bytes);

  /// true when the native server has room for more answer bytes, so a
  /// [flush] would complete at once. Before the first part it is false:
  /// the first flush starts the stream.
  bool get hasRoom => _response.hasRoom;

  /// Sends what was added. Completes when the native server has room for
  /// more, so a fast writer waits for a slow client.
  Future<void> flush() => _response.flush();

  /// Ends the answer. Trailers set with [setTrailer] go out after the body.
  void end() => _response.end();

  /// A plain HTTP answer, for requests that are not gRPC at all.
  void reject(int status, String text) {
    _response
      ..statusCode = status
      ..headers.contentType = ContentType.text
      ..write(text)
      ..end();
  }
}
