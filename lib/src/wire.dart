import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dox_grpc/src/grpc_status.dart';

/// One gRPC message as it came on the wire.
class GrpcFrame {
  const GrpcFrame(this.compressed, this.data);

  /// the compressed flag (the first byte of the frame)
  final bool compressed;

  /// the message bytes, still compressed when [compressed]
  final Uint8List data;
}

/// Reads gRPC messages from a body that comes in parts. A message may be
/// split over many parts, and one part may hold many messages.
///
/// Each message is 1 byte (the compressed flag), 4 bytes (the length, big
/// endian), then the message.
class GrpcMessageReader {
  GrpcMessageReader(this.maxMessageSize);

  /// a bigger message throws [GrpcStatus.resourceExhausted]
  final int maxMessageSize;

  final Uint8List _head = Uint8List(5);
  int _headLength = 0;
  Uint8List? _body;
  int _bodyLength = 0;

  /// true when a message started but did not end yet
  bool get hasPartial => _headLength > 0;

  /// Adds the next [part] of the body and gives the messages that are now
  /// whole. Throws [GrpcException] for a message over [maxMessageSize],
  /// before its bytes are kept.
  List<GrpcFrame> add(Uint8List part) {
    List<GrpcFrame> frames = <GrpcFrame>[];
    int i = 0;
    while (i < part.length) {
      if (_headLength < 5) {
        int take = _min(5 - _headLength, part.length - i);
        _head.setRange(_headLength, _headLength + take, part, i);
        _headLength += take;
        i += take;
        if (_headLength < 5) break;
        int length = ByteData.sublistView(_head).getUint32(1);
        if (length > maxMessageSize) {
          throw GrpcException(
            GrpcStatus.resourceExhausted,
            'Received message larger than max ($length vs. $maxMessageSize)',
          );
        }
        _body = Uint8List(length);
        _bodyLength = 0;
      }
      Uint8List body = _body!;
      int take = _min(body.length - _bodyLength, part.length - i);
      body.setRange(_bodyLength, _bodyLength + take, part, i);
      _bodyLength += take;
      i += take;
      if (_bodyLength == body.length) {
        frames.add(GrpcFrame(_head[0] == 1, body));
        _headLength = 0;
        _body = null;
      }
    }
    return frames;
  }

  static int _min(int a, int b) => a < b ? a : b;
}

/// Small pieces of the gRPC wire format.
class GrpcWire {
  GrpcWire._();

  /// [message] with the 5 byte frame head in front
  static Uint8List frame(List<int> message, {bool compressed = false}) {
    Uint8List out = Uint8List(5 + message.length);
    ByteData.sublistView(out)
      ..setUint8(0, compressed ? 1 : 0)
      ..setUint32(1, message.length);
    out.setRange(5, out.length, message);
    return out;
  }

  /// The `grpc-timeout` header as a [Duration]: at most 8 digits, then a
  /// unit (`H`, `M`, `S`, `m`, `u` or `n`). null when it is missing or
  /// not valid.
  static Duration? parseTimeout(String? value) {
    if (value == null || value.length < 2 || value.length > 9) return null;
    String digits = value.substring(0, value.length - 1);
    for (int c in digits.codeUnits) {
      if (c < 0x30 || c > 0x39) return null;
    }
    int n = int.parse(digits);
    return switch (value[value.length - 1]) {
      'H' => Duration(hours: n),
      'M' => Duration(minutes: n),
      'S' => Duration(seconds: n),
      'm' => Duration(milliseconds: n),
      'u' => Duration(microseconds: n),
      // ponytail: below 1 µs rounds up to 1 µs, Dart has no finer timer
      'n' => Duration(microseconds: (n + 999) ~/ 1000),
      _ => null,
    };
  }

  /// `grpc-message` text: UTF-8, then every byte outside space to `~`,
  /// and `%` itself, becomes `%XX`.
  static String percentEncode(String message) {
    StringBuffer out = StringBuffer();
    for (int b in utf8.encode(message)) {
      if (b >= 0x20 && b <= 0x7E && b != 0x25) {
        out.writeCharCode(b);
      } else {
        out
          ..write('%')
          ..write(b.toRadixString(16).toUpperCase().padLeft(2, '0'));
      }
    }
    return out.toString();
  }

  /// Bytes as the text of a `-bin` header: base64 with no padding.
  static String encodeBinary(List<int> bytes) {
    String text = base64.encode(bytes);
    int end = text.length;
    while (end > 0 && text.codeUnitAt(end - 1) == 0x3D) {
      end--;
    }
    return text.substring(0, end);
  }

  /// The bytes of a `-bin` header. Takes base64 with or without padding,
  /// and the URL-safe letters too. Throws [FormatException] when it is
  /// not base64.
  static Uint8List decodeBinary(String text) {
    String clean = text.trim();
    while (clean.endsWith('=')) {
      clean = clean.substring(0, clean.length - 1);
    }
    return base64.decode(clean.padRight((clean.length + 3) & ~3, '='));
  }

  /// gzip of [data]
  static Uint8List gzipEncode(List<int> data) {
    return Uint8List.fromList(gzip.encode(data));
  }

  /// Unzips [data]. Stops with [GrpcStatus.resourceExhausted] as soon as
  /// the result passes [max] bytes, so a small zip bomb can not fill the
  /// memory.
  static Uint8List gzipDecode(Uint8List data, int max) {
    _LimitedSink sink = _LimitedSink(max);
    ByteConversionSink input = gzip.decoder.startChunkedConversion(sink);
    const int step = 16 * 1024;
    try {
      for (int i = 0; i < data.length; i += step) {
        int end = i + step < data.length ? i + step : data.length;
        input.addSlice(data, i, end, false);
      }
      input.close();
    } on GrpcException {
      rethrow;
    } on Object {
      throw GrpcException(GrpcStatus.internal, 'Could not unzip the message');
    }
    return sink.bytes.takeBytes();
  }
}

/// Collects unzipped bytes up to a limit.
class _LimitedSink implements Sink<List<int>> {
  _LimitedSink(this.max);

  final int max;
  final BytesBuilder bytes = BytesBuilder(copy: false);

  @override
  void add(List<int> chunk) {
    if (bytes.length + chunk.length > max) {
      throw GrpcException(
        GrpcStatus.resourceExhausted,
        'Received message larger than max after unzip (max $max)',
      );
    }
    bytes.add(chunk);
  }

  @override
  void close() {}
}
