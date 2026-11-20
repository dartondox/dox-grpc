import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/dox_grpc.dart';

/// Loads the routes, reads a health status and ends, like a script that
/// builds the OpenAPI file. It must exit: no port may stay open.
void main() {
  HealthService health = HealthService();
  Grpc.register(health);
  health.setStatus('svc', ServingStatus.NOT_SERVING);
  health.statusOf('svc');
  Dox().initialize(AppConfig(appKey: 'a' * 32, serverPort: 0, http2: true));
  Dox().loadRoutes();
  print('routes loaded');
}
