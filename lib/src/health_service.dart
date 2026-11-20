import 'dart:async';

import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/src/generated/grpc/health/v1/health.pbgrpc.dart';
import 'package:dox_grpc/src/grpc_status.dart';
import 'package:grpc/service_api.dart';

/// The serving status of a service in the health check.
typedef ServingStatus = HealthCheckResponse_ServingStatus;

/// A message between the isolates of the app, about the health status.
/// [toWire] and [fromWire] turn it into simple values for the bus.
sealed class HealthMessage {
  const HealthMessage();

  /// Simple values that a port can send.
  List<Object> toWire();

  /// The message for [raw], or null when it is not a health message.
  static HealthMessage? fromWire(Object? raw) {
    if (raw is! List<Object?> || raw.isEmpty) return null;
    if (raw.length == 1 && raw[0] == 'sync') return const HealthSyncRequest();
    if (raw.length == 1 && raw[0] == 'done') return const HealthSyncDone();
    if (raw.length == 4 &&
        raw[0] == 'set' &&
        raw[1] is String &&
        raw[2] is int &&
        raw[3] is int) {
      return HealthChange(raw[1] as String, raw[2] as int, raw[3] as int);
    }
    return null;
  }
}

/// "Tell me what you have": sent by an isolate that just joined.
final class HealthSyncRequest extends HealthMessage {
  const HealthSyncRequest();

  @override
  List<Object> toWire() => const <Object>['sync'];
}

/// "That was all I have": the end of the answer to a [HealthSyncRequest].
final class HealthSyncDone extends HealthMessage {
  const HealthSyncDone();

  @override
  List<Object> toWire() => const <Object>['done'];
}

/// A status of [service] was set. [value] is the number of the
/// [ServingStatus], or -1 when the status was cleared. [at] is the time of
/// the change, the newest change wins.
final class HealthChange extends HealthMessage {
  const HealthChange(this.service, this.value, this.at);

  final String service;
  final int value;
  final int at;

  @override
  List<Object> toWire() => <Object>['set', service, value, at];
}

/// Carries health status changes to the other isolates of the app.
abstract class HealthSync {
  /// messages from the other isolates (never this one's own)
  Stream<HealthMessage> get messages;

  /// sends [message] to the other isolates
  void publish(HealthMessage message);

  /// how many other isolates the app has. 0 when it runs in one isolate.
  int get peers;
}

/// [HealthSync] on the Dox [IsolateBus], channel `dox_grpc.health`.
class IsolateBusHealthSync implements HealthSync {
  const IsolateBusHealthSync();

  static const String channel = 'dox_grpc.health';

  @override
  Stream<HealthMessage> get messages async* {
    await for (Object? raw in IsolateBus.instance.on(channel)) {
      HealthMessage? message = HealthMessage.fromWire(raw);
      if (message != null) yield message;
    }
  }

  @override
  void publish(HealthMessage message) {
    IsolateBus.instance.publish(channel, message.toWire());
  }

  @override
  int get peers => Dox().isolateCount - 1;
}

/// The standard gRPC health service (`grpc.health.v1.Health`), with
/// `Check` and `Watch`. Load balancers and `grpc_health_probe` use it.
///
/// The empty name `''` is the whole server. It starts as `SERVING`. Any
/// other service is unknown until you set it.
/// ```
/// HealthService health = HealthService();
/// Grpc.register(health);
/// health.setStatus('helloworld.Greeter', ServingStatus.SERVING);
/// ```
/// A change in one isolate goes to the other isolates of the app too.
class HealthService extends HealthServiceBase {
  HealthService({this._sync = const IsolateBusHealthSync()}) {
    // not a join here: the constructor also runs for `dox route:list`,
    // and a join opens a port. The join comes when the server starts.
    Dox().addProvider(_JoinOnBoot(this));
  }

  final HealthSync _sync;

  /// how long the first `Check` or `Watch` of an isolate waits for the
  /// other isolates to tell their status
  static const Duration syncWait = Duration(milliseconds: 300);

  /// service => (status value, or -1 when cleared; the time of the change)
  final Map<String, (int, int)> _entries = <String, (int, int)>{
    '': (ServingStatus.SERVING.value, 0),
  };

  /// the time of the last change seen. A new change gets a later time, so
  /// the newest change wins in every isolate.
  int _clock = 0;

  final StreamController<String> _changes =
      StreamController<String>.broadcast();

  /// The bus state of each instance, per isolate. Not a field: an
  /// instance is copied to the other isolates when the server starts,
  /// and each copy must join in its own isolate.
  static final Expando<_Join> _joins = Expando<_Join>();

  /// Sets the status of [service], in all isolates. `Watch` callers get
  /// it at once.
  void setStatus(String service, ServingStatus status) {
    _change(service, status.value);
  }

  /// Removes [service]: it is unknown again, in all isolates.
  void clearStatus(String service) => _change(service, -1);

  /// the status of [service], null when it is unknown
  ServingStatus? statusOf(String service) {
    join();
    (int, int)? entry = _entries[service];
    if (entry == null || entry.$1 < 0) return null;
    return ServingStatus.valueOf(entry.$1);
  }

  /// Listens to the other isolates, once per isolate, and asks them for
  /// what they have. Dox calls it when the server starts in each isolate.
  /// Later calls do nothing.
  void join() {
    if (_joins[this] != null) return;
    _Join state = _joins[this] = _Join();
    state.subscription = _sync.messages.listen(_onMessage);
    _sync.publish(const HealthSyncRequest());
  }

  /// Waits (at most [syncWait]) until the other isolates told what they
  /// have, so the first answer of a new isolate is not stale. It does not
  /// wait in an app with one isolate, or when the sync is done.
  Future<void> _synced() async {
    join();
    Completer<void> done = _joins[this]!.synced;
    if (done.isCompleted || _sync.peers < 1) return;
    await done.future.timeout(syncWait, onTimeout: _nothing);
  }

  static void _nothing() {}

  @override
  Future<HealthCheckResponse> check(
    ServiceCall call,
    HealthCheckRequest request,
  ) async {
    await _synced();
    ServingStatus? status = statusOf(request.service);
    if (status == null) {
      throw GrpcException(GrpcStatus.notFound, 'Unknown service');
    }
    return HealthCheckResponse(status: status);
  }

  @override
  Stream<HealthCheckResponse> watch(
    ServiceCall call,
    HealthCheckRequest request,
  ) {
    return _HealthWatch(this, request.service).stream;
  }

  ServingStatus _current(String service) {
    return statusOf(service) ?? ServingStatus.SERVICE_UNKNOWN;
  }

  void _change(String service, int value) {
    join();
    int now = DateTime.now().microsecondsSinceEpoch;
    _clock = now > _clock ? now : _clock + 1;
    if (_apply(service, value, _clock)) {
      _sync.publish(HealthChange(service, value, _clock));
    }
  }

  /// Keeps the change when it is newer than the one we have.
  bool _apply(String service, int value, int at) {
    if (at > _clock) _clock = at;
    (int, int)? old = _entries[service];
    if (old != null && old.$2 >= at) return false;
    _entries[service] = (value, at);
    if (old?.$1 != value) _changes.add(service);
    return true;
  }

  void _onMessage(HealthMessage message) {
    switch (message) {
      case HealthSyncRequest():
        _entries.forEach(_send);
        _sync.publish(const HealthSyncDone());
      case HealthSyncDone():
        Completer<void>? done = _joins[this]?.synced;
        if (done != null && !done.isCompleted) done.complete();
      case HealthChange():
        _apply(message.service, message.value, message.at);
    }
  }

  void _send(String service, (int, int) entry) {
    if (entry.$2 == 0) return; // the start value, every isolate has it
    _sync.publish(HealthChange(service, entry.$1, entry.$2));
  }
}

/// One `Watch` call. A plain `async*` method is not used here: a cancel
/// would wait there until the next status change, and the call would stay
/// open until then.
class _HealthWatch {
  _HealthWatch(this._health, this._service) {
    _out = StreamController<HealthCheckResponse>(
      onListen: _start,
      onCancel: _stop,
    );
  }

  final HealthService _health;
  final String _service;
  late final StreamController<HealthCheckResponse> _out;
  StreamSubscription<String>? _subscription;
  ServingStatus _last = ServingStatus.SERVICE_UNKNOWN;
  bool _stopped = false;

  Stream<HealthCheckResponse> get stream => _out.stream;

  Future<void> _start() async {
    await _health._synced();
    if (_stopped) return;
    _last = _health._current(_service);
    _out.add(HealthCheckResponse(status: _last));
    _subscription = _health._changes.stream.listen(_onChange);
  }

  void _onChange(String changed) {
    if (changed != _service) return;
    ServingStatus now = _health._current(_service);
    if (now == _last) return;
    _last = now;
    _out.add(HealthCheckResponse(status: now));
  }

  Future<void> _stop() async {
    _stopped = true;
    await _subscription?.cancel();
  }
}

/// what one isolate keeps for its bus join
class _Join {
  StreamSubscription<HealthMessage>? subscription;

  /// completes when another isolate said it told all it has
  final Completer<void> synced = Completer<void>();
}

/// Joins the bus when the server starts in an isolate, so the first
/// `Check` there already has the status of the other isolates. The
/// provider list goes to every isolate with the services.
class _JoinOnBoot extends DoxProvider {
  _JoinOnBoot(this._health);

  final HealthService _health;

  @override
  void setup() {}

  @override
  void boot() => _health.join();
}
