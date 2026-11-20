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
  final StreamController<Object?> _in = StreamController<Object?>.broadcast();

  @override
  Stream<Object?> get messages => _in.stream;

  @override
  void publish(List<Object> message) {
    for (FakeSync other in bus.members) {
      if (!identical(other, this)) other._in.add(List<Object>.of(message));
    }
  }
}

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('a change goes to the other isolates', () async {
    FakeBus bus = FakeBus();
    HealthService a = HealthService(sync: bus.join());
    HealthService b = HealthService(sync: bus.join());
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
    await settle();
    await settle();
    expect(late.statusOf('svc'), ServingStatus.NOT_SERVING);
  });

  test('an older change does not win over a newer one', () async {
    FakeBus bus = FakeBus();
    HealthService a = HealthService(sync: bus.join());
    HealthService b = HealthService(sync: bus.join());
    a.setStatus('svc', ServingStatus.SERVING);
    b.setStatus('svc', ServingStatus.NOT_SERVING); // later
    await settle();
    expect(a.statusOf('svc'), ServingStatus.NOT_SERVING);
    expect(b.statusOf('svc'), ServingStatus.NOT_SERVING);
  });
}
