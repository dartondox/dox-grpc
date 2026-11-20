import 'dart:math';

import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/dox_grpc.dart';
import 'package:dox_grpc/src/generated/grpc/health/v1/health.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:test/test.dart';

String randomKey() {
  Random random = Random.secure();
  return String.fromCharCodes(
    List<int>.generate(32, (int _) => 0x61 + random.nextInt(26)),
  );
}

void main() {
  test(
    'two isolates: the services are copied, health changes reach both',
    () async {
      HealthService health = HealthService();
      Grpc.register(health);
      Dox().initialize(
        AppConfig(
          appKey: randomKey(),
          serverPort: 0,
          totalIsolate: 2,
          http2: true,
        ),
      );
      await Dox().startServer();
      int port = Dox().server.httpServer.port;
      // let the second isolate join the bus
      await Future<void>.delayed(const Duration(milliseconds: 300));
      health.setStatus('svc', ServingStatus.NOT_SERVING);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // new connections, so both isolates answer some of them. Linux spreads
      // them over the isolates. macOS gives them all to one, so there this
      // test only shows that the services copy to the second isolate.
      Set<ServingStatus> seen = <ServingStatus>{};
      for (int i = 0; i < 20; i++) {
        ClientChannel channel = ClientChannel(
          '127.0.0.1',
          port: port,
          options: const ChannelOptions(
            credentials: ChannelCredentials.insecure(),
          ),
        );
        HealthCheckResponse res = await HealthClient(channel)
            .check(HealthCheckRequest(service: 'svc'));
        seen.add(res.status);
        await channel.shutdown();
      }
      expect(seen, <ServingStatus>{ServingStatus.NOT_SERVING});
      await Dox().server.close();
    },
  );
}
