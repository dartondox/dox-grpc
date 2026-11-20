import 'dart:convert';
import 'dart:typed_data';

import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/dox_grpc.dart';
import 'package:dox_grpc/src/grpc.dart';
import 'package:dox_grpc/src/wire.dart';
import 'package:test/test.dart';

Uint8List bytes(String text) => Uint8List.fromList(utf8.encode(text));

void main() {
  group('GrpcMessageReader', () {
    test('a message in 1-byte parts', () {
      GrpcMessageReader reader = GrpcMessageReader(1024);
      Uint8List wire = GrpcWire.frame(bytes('hello'));
      List<GrpcFrame> frames = <GrpcFrame>[];
      for (int b in wire) {
        frames.addAll(reader.add(Uint8List.fromList(<int>[b])));
        if (frames.isEmpty) expect(reader.hasPartial, isTrue);
      }
      expect(frames, hasLength(1));
      expect(utf8.decode(frames.single.data), 'hello');
      expect(frames.single.compressed, isFalse);
      expect(reader.hasPartial, isFalse);
    });

    test('many messages in one part, and an empty message', () {
      GrpcMessageReader reader = GrpcMessageReader(1024);
      BytesBuilder all = BytesBuilder()
        ..add(GrpcWire.frame(bytes('a')))
        ..add(GrpcWire.frame(<int>[]))
        ..add(GrpcWire.frame(bytes('ccc'), compressed: true));
      List<GrpcFrame> frames = reader.add(all.takeBytes());
      expect(frames.map((GrpcFrame f) => utf8.decode(f.data)), <String>[
        'a',
        '',
        'ccc',
      ]);
      expect(frames.last.compressed, isTrue);
    });

    test('a split over a part boundary in the head and in the body', () {
      GrpcMessageReader reader = GrpcMessageReader(1024);
      Uint8List wire = Uint8List.fromList(<int>[
        ...GrpcWire.frame(bytes('first')),
        ...GrpcWire.frame(bytes('second')),
      ]);
      expect(reader.add(wire.sublist(0, 3)), isEmpty);
      List<GrpcFrame> a = reader.add(wire.sublist(3, 13));
      expect(a.map((GrpcFrame f) => utf8.decode(f.data)), <String>['first']);
      List<GrpcFrame> b = reader.add(wire.sublist(13));
      expect(b.map((GrpcFrame f) => utf8.decode(f.data)), <String>['second']);
    });

    test('a declared length does not allocate that much at once', () {
      GrpcMessageReader reader = GrpcMessageReader(4 * 1024 * 1024);
      Uint8List head = Uint8List(5);
      ByteData.sublistView(head).setUint32(1, 4 * 1024 * 1024);
      expect(reader.add(head), isEmpty);
      expect(reader.bufferedCapacity, lessThanOrEqualTo(64 * 1024));
    });

    test('a big message in parts keeps every byte', () {
      GrpcMessageReader reader = GrpcMessageReader(4 * 1024 * 1024);
      Uint8List message = Uint8List(1000 * 1000 + 7);
      for (int i = 0; i < message.length; i++) {
        message[i] = (i * 31) & 0xff;
      }
      Uint8List wire = GrpcWire.frame(message);
      List<GrpcFrame> frames = <GrpcFrame>[];
      for (int i = 0; i < wire.length; i += 70000) {
        int end = i + 70000 < wire.length ? i + 70000 : wire.length;
        frames.addAll(reader.add(wire.sublist(i, end)));
      }
      expect(frames, hasLength(1));
      expect(frames.single.data, message);
    });

    test('a message over the limit throws before its body comes', () {
      GrpcMessageReader reader = GrpcMessageReader(4);
      Uint8List head = GrpcWire.frame(bytes('12345')).sublist(0, 5);
      expect(
        () => reader.add(head),
        throwsA(
          isA<GrpcException>().having(
            (GrpcException e) => e.status,
            'status',
            GrpcStatus.resourceExhausted,
          ),
        ),
      );
    });

    test('a message at the limit is fine', () {
      GrpcMessageReader reader = GrpcMessageReader(5);
      expect(reader.add(GrpcWire.frame(bytes('12345'))), hasLength(1));
    });
  });

  group('parseTimeout', () {
    test('all units', () {
      expect(GrpcWire.parseTimeout('2H'), const Duration(hours: 2));
      expect(GrpcWire.parseTimeout('3M'), const Duration(minutes: 3));
      expect(GrpcWire.parseTimeout('4S'), const Duration(seconds: 4));
      expect(GrpcWire.parseTimeout('100m'), const Duration(milliseconds: 100));
      expect(GrpcWire.parseTimeout('7u'), const Duration(microseconds: 7));
      expect(GrpcWire.parseTimeout('1500n'), const Duration(microseconds: 2));
      expect(GrpcWire.parseTimeout('99999999S'), isNotNull);
    });

    test('bad values give null', () {
      for (String bad in <String>[
        '',
        'S',
        '5',
        '5x',
        '-5S',
        '5 S',
        '1.5S',
        '123456789S',
      ]) {
        expect(GrpcWire.parseTimeout(bad), isNull, reason: bad);
      }
      expect(GrpcWire.parseTimeout(null), isNull);
    });
  });

  test('percentEncode', () {
    expect(GrpcWire.percentEncode('plain text ~!'), 'plain text ~!');
    expect(GrpcWire.percentEncode('100%'), '100%25');
    expect(GrpcWire.percentEncode('a\nb'), 'a%0Ab');
    expect(GrpcWire.percentEncode('ü'), '%C3%BC');
    expect(Uri.decodeComponent(GrpcWire.percentEncode('ü 100%')), 'ü 100%');
  });

  test('binary metadata: padded, unpadded and URL-safe base64', () {
    Uint8List data = Uint8List.fromList(<int>[0xab, 0xab, 0xab, 0xfb, 0xff]);
    String text = GrpcWire.encodeBinary(data);
    expect(text.endsWith('='), isFalse);
    expect(GrpcWire.decodeBinary(text), data);
    expect(GrpcWire.decodeBinary(base64.encode(data)), data);
    expect(GrpcWire.decodeBinary(base64Url.encode(data)), data);
    expect(() => GrpcWire.decodeBinary('!!'), throwsFormatException);
  });

  group('gzip', () {
    test('round trip', () {
      Uint8List data = bytes('hello ' * 1000);
      Uint8List zipped = GrpcWire.gzipEncode(data);
      expect(zipped.length, lessThan(data.length));
      expect(GrpcWire.gzipDecode(zipped, data.length), data);
    });

    test('stops when the unzipped size passes the limit', () {
      Uint8List zipped = GrpcWire.gzipEncode(Uint8List(1024 * 1024));
      expect(
        () => GrpcWire.gzipDecode(zipped, 1000),
        throwsA(
          isA<GrpcException>().having(
            (GrpcException e) => e.status,
            'status',
            GrpcStatus.resourceExhausted,
          ),
        ),
      );
    });

    test('bad bytes are INTERNAL', () {
      expect(
        () => GrpcWire.gzipDecode(bytes('not gzip'), 1000),
        throwsA(
          isA<GrpcException>().having(
            (GrpcException e) => e.status,
            'status',
            GrpcStatus.internal,
          ),
        ),
      );
    });
  });

  test('GrpcStatus has the 17 codes in order', () {
    expect(GrpcStatus.values, hasLength(17));
    for (GrpcStatus status in GrpcStatus.values) {
      expect(GrpcStatus.fromCode(status.code), status);
    }
    expect(GrpcStatus.unimplemented.code, 12);
    expect(GrpcStatus.unauthenticated.code, 16);
    expect(GrpcStatus.fromCode(99), GrpcStatus.unknown);
    expect(GrpcStatus.fromCode(-1), GrpcStatus.unknown);
  });

  test('content type check', () {
    expect(GrpcServiceRoute.isGrpcType('application/grpc'), isTrue);
    expect(GrpcServiceRoute.isGrpcType('application/grpc+proto'), isTrue);
    expect(GrpcServiceRoute.isGrpcType('Application/GRPC; x=1'), isTrue);
    expect(GrpcServiceRoute.isGrpcType('application/grpc+json'), isFalse);
    expect(GrpcServiceRoute.isGrpcType('application/json'), isFalse);
    expect(GrpcServiceRoute.isGrpcType(null), isFalse);
  });

  group('an HTTP error from a middleware', () {
    test('keeps its message for 4xx', () {
      GrpcException e = GrpcServiceRoute.toGrpcException(
        HttpStatusException(401, message: 'no token'),
        debug: false,
      );
      expect(e.status, GrpcStatus.unauthenticated);
      expect(e.message, 'no token');
    });

    test('hides the message for 5xx outside debug', () {
      GrpcException e = GrpcServiceRoute.toGrpcException(
        HttpStatusException(503, message: 'db password is x'),
        debug: false,
      );
      expect(e.status, GrpcStatus.unavailable);
      expect(e.message, 'Internal error');
    });

    test('shows the message for 5xx in debug', () {
      GrpcException e = GrpcServiceRoute.toGrpcException(
        HttpStatusException(503, message: 'db is down'),
        debug: true,
      );
      expect(e.message, 'db is down');
    });
  });

  test('an invalid compressed flag is INTERNAL', () {
    GrpcMessageReader reader = GrpcMessageReader(1024);
    Uint8List frame = GrpcWire.frame(bytes('x'));
    frame[0] = 2;
    expect(
      () => reader.add(frame),
      throwsA(
        isA<GrpcException>().having(
          (GrpcException e) => e.status,
          'status',
          GrpcStatus.internal,
        ),
      ),
    );
  });
}
