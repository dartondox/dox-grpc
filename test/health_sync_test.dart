import 'dart:async';
import 'dart:io';

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

  /// a message from another isolate
  void deliver(HealthMessage message) => _in.add(message);
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
    a.join();
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

  test('before join, a status stays local and the bus is not used', () async {
    FakeBus bus = FakeBus();
    FakeSync sync = bus.join();
    FakeSync other = bus.join();
    HealthService health = HealthService(sync: sync);
    List<HealthMessage> seen = <HealthMessage>[];
    other.messages.listen(seen.add);
    health.setStatus('svc', ServingStatus.NOT_SERVING);
    health.clearStatus('x');
    expect(health.statusOf('svc'), ServingStatus.NOT_SERVING);
    await health.check(NoCall(), HealthCheckRequest()); // does not wait
    await settle();
    expect(sync.joined, isFalse);
    expect(seen, isEmpty);
    // at join, the local status goes out
    health.join();
    await settle();
    expect(sync.joined, isTrue);
    expect(
      seen.whereType<HealthChange>().map((HealthChange c) => c.service),
      containsAll(<String>['svc', 'x']),
    );
  });

  test('a tie on the time: every isolate ends with the same status', () async {
    FakeBus bus = FakeBus();
    FakeSync syncA = bus.join();
    FakeSync syncB = bus.join();
    HealthService a = HealthService(sync: syncA);
    HealthService b = HealthService(sync: syncB);
    a.join();
    b.join();
    await settle();
    // the same time, different values, each isolate sees the other's last
    HealthChange serving = HealthChange('svc', ServingStatus.SERVING.value, 5);
    HealthChange notServing = HealthChange(
      'svc',
      ServingStatus.NOT_SERVING.value,
      5,
    );
    syncA.deliver(serving);
    syncB.deliver(notServing);
    syncA.deliver(notServing);
    syncB.deliver(serving);
    await settle();
    expect(a.statusOf('svc'), b.statusOf('svc'));
    expect(a.statusOf('svc'), ServingStatus.NOT_SERVING);
  });

  test('the first Check of a late joiner is not stale', () async {
    FakeBus bus = FakeBus();
    HealthService a = HealthService(sync: bus.join());
    a.join();
    a.setStatus('svc', ServingStatus.NOT_SERVING);
    HealthService late = HealthService(sync: bus.join());
    late.join();
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
      a.join();
      a.setStatus('svc', ServingStatus.NOT_SERVING);
      HealthService late = HealthService(sync: bus.join());
      late.join();
      HealthCheckResponse first = await late
          .watch(NoCall(), HealthCheckRequest(service: 'svc'))
          .first;
      expect(first.status, ServingStatus.NOT_SERVING);
    },
  );

  test('with no other isolate, Check does not wait', () async {
    FakeBus bus = FakeBus();
    HealthService alone = HealthService(sync: bus.join());
    alone.join();
    HealthCheckResponse res = await alone
        .check(NoCall(), HealthCheckRequest())
        .timeout(HealthService.syncWait ~/ 3);
    expect(res.status, ServingStatus.SERVING);
  });

  test('a silent isolate costs one wait, not one per Check', () async {
    FakeBus bus = FakeBus();
    bus.join(); // a member that never answers
    HealthService health = HealthService(sync: bus.join());
    health.join();
    Stopwatch watch = Stopwatch()..start();
    HealthCheckResponse res = await health.check(
      NoCall(),
      HealthCheckRequest(),
    );
    expect(res.status, ServingStatus.SERVING);
    expect(watch.elapsed, greaterThan(HealthService.syncWait ~/ 2));
    // the next ones do not wait again
    watch.reset();
    for (int i = 0; i < 3; i++) {
      await health.check(NoCall(), HealthCheckRequest());
    }
    expect(watch.elapsed, lessThan(HealthService.syncWait ~/ 2));
  });

  test('a script that only loads the routes exits', () async {
    ProcessResult res = await Process.run(Platform.resolvedExecutable, <String>[
      'run',
      'test/fixtures/load_routes.dart',
    ]).timeout(const Duration(seconds: 90));
    expect(res.exitCode, 0, reason: '${res.stdout}${res.stderr}');
    expect(res.stdout, contains('routes loaded'));
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
