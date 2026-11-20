import 'dart:async';

import 'package:dox_grpc/src/generated/grpc/health/v1/health.pbgrpc.dart';
import 'package:dox_grpc/src/grpc_status.dart';
import 'package:grpc/service_api.dart';

/// The serving status of a service in the health check.
typedef ServingStatus = HealthCheckResponse_ServingStatus;

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
/// The status lives in one isolate. With more isolates, set it in each one
/// (eg. in a provider).
class HealthService extends HealthServiceBase {
  final Map<String, ServingStatus> _status = <String, ServingStatus>{
    '': ServingStatus.SERVING,
  };

  final StreamController<String> _changes =
      StreamController<String>.broadcast();

  /// Sets the status of [service]. `Watch` callers get it at once.
  void setStatus(String service, ServingStatus status) {
    if (_status[service] == status) return;
    _status[service] = status;
    _changes.add(service);
  }

  /// Removes [service]: it is unknown again.
  void clearStatus(String service) {
    if (_status.remove(service) != null) _changes.add(service);
  }

  /// the status of [service], null when it is unknown
  ServingStatus? statusOf(String service) => _status[service];

  @override
  Future<HealthCheckResponse> check(
    ServiceCall call,
    HealthCheckRequest request,
  ) async {
    ServingStatus? status = _status[request.service];
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
    ServingStatus? last = _current(service);
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
    return _status[service] ?? ServingStatus.SERVICE_UNKNOWN;
  }
}
