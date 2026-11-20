import 'dart:async';

import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/src/generated/grpc/health/v1/health.pbgrpc.dart';
import 'package:dox_grpc/src/grpc_status.dart';
import 'package:grpc/service_api.dart';

/// The serving status of a service in the health check.
typedef ServingStatus = HealthCheckResponse_ServingStatus;

/// Carries health status changes to the other isolates of the app.
abstract class HealthSync {
  /// messages from the other isolates (never this one's own)
  Stream<Object?> get messages;

  /// sends [message] to the other isolates. Only simple values.
  void publish(List<Object> message);
}

/// [HealthSync] on the Dox [IsolateBus], channel `dox_grpc.health`.
class IsolateBusHealthSync implements HealthSync {
  const IsolateBusHealthSync();

  static const String channel = 'dox_grpc.health';

  @override
  Stream<Object?> get messages => IsolateBus.instance.on(channel);

  @override
  void publish(List<Object> message) {
    IsolateBus.instance.publish(channel, message);
  }
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
    _join();
  }

  final HealthSync _sync;

  /// service => (status value, or -1 when cleared; the time of the change)
  final Map<String, (int, int)> _entries = <String, (int, int)>{
    '': (ServingStatus.SERVING.value, 0),
  };

  /// the time of the last change seen. A new change gets a later time, so
  /// the newest change wins in every isolate.
  int _clock = 0;

  final StreamController<String> _changes =
      StreamController<String>.broadcast();

  /// The bus listener of each instance, per isolate. Not a field: an
  /// instance is copied to the other isolates when the server starts,
  /// and each copy must listen in its own isolate.
  static final Expando<StreamSubscription<Object?>> _listeners =
      Expando<StreamSubscription<Object?>>();

  /// Sets the status of [service], in all isolates. `Watch` callers get
  /// it at once.
  void setStatus(String service, ServingStatus status) {
    _change(service, status.value);
  }

  /// Removes [service]: it is unknown again, in all isolates.
  void clearStatus(String service) => _change(service, -1);

  /// the status of [service], null when it is unknown
  ServingStatus? statusOf(String service) {
    _join();
    (int, int)? entry = _entries[service];
    if (entry == null || entry.$1 < 0) return null;
    return ServingStatus.valueOf(entry.$1);
  }

  @override
  Future<HealthCheckResponse> check(
    ServiceCall call,
    HealthCheckRequest request,
  ) async {
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
  ) async* {
    String service = request.service;
    ServingStatus last = _current(service);
    yield HealthCheckResponse(status: last);
    await for (String changed in _changes.stream) {
      if (changed != service) continue;
      ServingStatus now = _current(service);
      if (now == last) continue;
      last = now;
      yield HealthCheckResponse(status: now);
    }
  }

  ServingStatus _current(String service) {
    return statusOf(service) ?? ServingStatus.SERVICE_UNKNOWN;
  }

  void _change(String service, int value) {
    _join();
    int now = DateTime.now().microsecondsSinceEpoch;
    _clock = now > _clock ? now : _clock + 1;
    if (_apply(service, value, _clock)) {
      _sync.publish(<Object>['set', service, value, _clock]);
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

  /// Listens to the other isolates, once per isolate, and asks them for
  /// what they have.
  void _join() {
    if (_listeners[this] != null) return;
    _listeners[this] = _sync.messages.listen(_onMessage);
    _sync.publish(<Object>['sync']);
  }

  void _onMessage(Object? message) {
    if (message is! List<Object?> || message.isEmpty) return;
    if (message[0] == 'sync') {
      _entries.forEach(_send);
      return;
    }
    if (message.length == 4 &&
        message[0] == 'set' &&
        message[1] is String &&
        message[2] is int &&
        message[3] is int) {
      _apply(message[1] as String, message[2] as int, message[3] as int);
    }
  }

  void _send(String service, (int, int) entry) {
    if (entry.$2 == 0) return; // the start value, every isolate has it
    _sync.publish(<Object>['set', service, entry.$1, entry.$2]);
  }
}
