import 'dart:io';

import 'package:dox_annotation/command.dart';
import 'package:dox_annotation/install.dart';

/// `dox grpc:install`. `dox add grpc` runs it. It sets up gRPC in an app:
/// a sample `.proto` file, a `GrpcRouter` with the health service, and the
/// `APP_HTTP2` key in `.env`. It never overwrites a file and never changes
/// a key that is there, so it is safe to run twice.
class GrpcInstallCommand extends Command {
  /// [root] is the app folder (the current folder by default). [runner]
  /// runs `dart`, tests pass a fake one.
  GrpcInstallCommand({this.root, this.runner});

  final Directory? root;
  final ProcessRunner? runner;

  @override
  String get name => 'grpc:install';

  @override
  String get description => 'Set up gRPC in this app';

  @override
  String get usage => 'grpc:install';

  @override
  Future<void> run(List<String> args) async {
    if (args.isNotEmpty) {
      print('Unknown option. grpc:install has no options.');
      exitCode = 1;
      return;
    }
    Installer installer = Installer(root: root, runner: runner);

    await installer.addDependency('dox_grpc');
    // the code that protoc makes imports these two
    await installer.addDependency('grpc');
    await installer.addDependency('protobuf');

    installer.writeFile('protos/greeter.proto', greeterProto);
    installer.writeFile('lib/routes/grpc.dart', grpcRouter);
    installer.addEnv('APP_HTTP2', 'true');

    installer.printSummary(<String>[
      'Turn on HTTP/2 in lib/config/app.dart: set `http2: true`. Or add an '
          '`appHttp2` getter to AppEnv, run `dart run build_runner build`, '
          'and set `http2: env.appHttp2`. Then APP_HTTP2 in .env controls it.',
      'Run `dart run build_runner build`, so the app finds GrpcRouter (a '
          'router in lib/routes is picked up by itself). If your app lists '
          'its routers by hand, add `GrpcRouter()` to that list.',
      'Install protoc (for example `brew install protobuf`) and its Dart '
          'plugin: `dart pub global activate protoc_plugin`.',
      'Make the Dart code: `mkdir -p lib/app/grpc && protoc '
          '--dart_out=grpc:lib/app/grpc -Iprotos protos/greeter.proto`.',
      'Write a service class that extends `GreeterServiceBase`, and register '
          'it in lib/routes/grpc.dart.',
      'Read the gRPC docs: https://dartondox.dev/digging-deeper/grpc/',
    ]);
  }

  /// `protos/greeter.proto`, a small sample service
  static const String greeterProto = '''
// Make the Dart code: protoc --dart_out=grpc:lib/app/grpc -Iprotos protos/greeter.proto
syntax = "proto3";

package greeter;

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply);
}

message HelloRequest {
  string name = 1;
}

message HelloReply {
  string message = 1;
}
''';

  /// `lib/routes/grpc.dart`. It has no prefix and no middleware: gRPC
  /// clients call `/<package.Service>/<method>` and nothing else.
  static const String grpcRouter = '''
import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/dox_grpc.dart';

/// Registers the gRPC services. Do not add a `prefix` or a `Route.middleware`
/// here: gRPC clients call `/<package.Service>/<method>` exactly.
class GrpcRouter extends Router {
  @override
  void register() {
    Grpc.register(HealthService());

    // Register your own services here, for example:
    // Grpc.register(GreeterService());
  }
}
''';
}
