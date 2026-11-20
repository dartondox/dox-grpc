import 'dart:async';

import 'package:dox_grpc/dox_grpc.dart';
import 'package:test/test.dart';

/// A bus between the "isolates" of a test: a message goes to every other
/// member, later (like a real port), never back to the sender.
class FakeBus {
  final List<FakeSync> members = <FakeSync>[];

  FakeSync join() {
    FakeSync sync = FakeSync(this);
    members.add(sync);
    return sync;
  }
}

class FakeSync implements HealthSync {
  FakeSync(this.bus);

  final FakeBus bus;
  final StreamController<HealthMessage> _in =
      StreamController<HealthMessage>.broadcast();

  /// true once someone listened to [messages]: the isolate joined
  bool joined = false;

  @override
  Stream<HealthMessage> get messages {
    joined = true;
    return _in.stream;
  }

  @override
  void publish(HealthMessage message) {
    for (FakeSync other in bus.members) {
      if (!identical(other, this)) other._in.add(message);
    }
  }

  @override
  int get peers => bus.members.length - 1;
}

/// the calls of `check` do not use the call
class NoCall implements ServiceCall {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('a change goes to the other isolates', () async {
    FakeBus bus = FakeBus();
    HealthService a = HealthService(sync: bus.join());
    HealthService b = HealthService(sync: bus.join());
    a.join();
    b.join();
    await settle();

    a.setStatus('svc', ServingStatus.NOT_SERVING);
    expect(a.statusOf('svc'), ServingStatus.NOT_SERVING);
    await settle();
    expect(b.statusOf('svc'), ServingStatus.NOT_SERVING);

    b.clearStatus('svc');
    await settle();
    expect(a.statusOf('svc'), isNull);
    expect(a.statusOf(''), ServingStatus.SERVING);
  });

  test('an isolate that joins late gets the current status', () async {
    FakeBus bus = FakeBus();
    HealthService a = HealthService(sync: bus.join());
    a.setStatus('svc', ServingStatus.SERVING);
    a.setStatus('svc', ServingStatus.NOT_SERVING);
    HealthService late = HealthService(sync: bus.join());
    late.join();
    await settle();
    await settle();
    expect(late.statusOf('svc'), ServingStatus.NOT_SERVING);
  });

  test('an older change does not win over a newer one', () async {
    FakeBus bus = FakeBus();
    HealthService a = HealthService(sync: bus.join());
    HealthService b = HealthService(sync: bus.join());
    a.join();
    b.join();
    a.setStatus('svc', ServingStatus.SERVING);
    b.setStatus('svc', ServingStatus.NOT_SERVING); // later
    await settle();
    expect(a.statusOf('svc'), ServingStatus.NOT_SERVING);
    expect(b.statusOf('svc'), ServingStatus.NOT_SERVING);
  });

  test('the constructor does not join the bus', () async {
    FakeBus bus = FakeBus();
    FakeSync sync = bus.join();
    HealthService health = HealthService(sync: sync);
    expect(sync.joined, isFalse);
    health.statusOf('');
    expect(sync.joined, isTrue);
  });

  test('the first Check of a late joiner is not stale', () async {
    FakeBus bus = FakeBus();
    HealthService a = HealthService(sync: bus.join());
    a.setStatus('svc', ServingStatus.NOT_SERVING);
    HealthService late = HealthService(sync: bus.join());
    // no settle: Check itself waits for the answer of the other isolate
    HealthCheckResponse res = await late.check(
      NoCall(),
      HealthCheckRequest(service: 'svc'),
    );
    expect(res.status, ServingStatus.NOT_SERVING);
  });

  test(
    'the first Watch of a late joiner starts with the real status',
    () async {
      FakeBus bus = FakeBus();
      HealthService a = HealthService(sync: bus.join());
      a.setStatus('svc', ServingStatus.NOT_SERVING);
      HealthService late = HealthService(sync: bus.join());
      HealthCheckResponse first = await late
          .watch(NoCall(), HealthCheckRequest(service: 'svc'))
          .first;
      expect(first.status, ServingStatus.NOT_SERVING);
    },
  );

  test('with no other isolate, Check does not wait', () async {
    FakeBus bus = FakeBus();
    HealthService alone = HealthService(sync: bus.join());
    HealthCheckResponse res = await alone
        .check(NoCall(), HealthCheckRequest())
        .timeout(HealthService.syncWait ~/ 3);
    expect(res.status, ServingStatus.SERVING);
  });

  test('Check waits only a short time for an isolate that is silent', () async {
    FakeBus bus = FakeBus();
    bus.join(); // a member that never answers
    HealthService health = HealthService(sync: bus.join());
    Stopwatch watch = Stopwatch()..start();
    HealthCheckResponse res = await health.check(
      NoCall(),
      HealthCheckRequest(),
    );
    expect(res.status, ServingStatus.SERVING);
    expect(watch.elapsed, lessThan(HealthService.syncWait * 5));
  });

  test('messages go to the wire and back', () {
    HealthChange change = HealthChange('svc', 2, 99);
    HealthChange back = HealthMessage.fromWire(change.toWire()) as HealthChange;
    expect(back.service, 'svc');
    expect(back.value, 2);
    expect(back.at, 99);
    expect(
      HealthMessage.fromWire(const HealthSyncRequest().toWire()),
      isA<HealthSyncRequest>(),
    );
    expect(
      HealthMessage.fromWire(const HealthSyncDone().toWire()),
      isA<HealthSyncDone>(),
    );
    expect(HealthMessage.fromWire(<Object>['set', 1]), isNull);
    expect(HealthMessage.fromWire('nope'), isNull);
  });
}
