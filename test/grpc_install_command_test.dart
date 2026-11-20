import 'dart:async';
import 'dart:io';

import 'package:dox_annotation/command.dart';
import 'package:dox_annotation/install.dart';
import 'package:dox_grpc/commands.dart';
import 'package:test/test.dart';

/// records the `dart` commands, runs nothing
class FakeRunner extends ProcessRunner {
  final List<String> calls = <String>[];

  @override
  Future<int> run(String executable, List<String> args, String folder) async {
    calls.add(args.join(' '));
    return 0;
  }
}

void main() {
  late Directory root;
  late FakeRunner runner;

  setUp(() {
    root = Directory.systemTemp.createTempSync('dox_grpc_install_');
    File(
      '${root.path}/pubspec.yaml',
    ).writeAsStringSync('name: my_app\n\ndependencies:\n  dox_core: ^3.2.0\n');
    File('${root.path}/.env').writeAsStringSync('APP_NAME=dox\n');
    File('${root.path}/.env.example').writeAsStringSync('APP_NAME=dox\n');
    runner = FakeRunner();
    exitCode = 0;
  });

  tearDown(() {
    root.deleteSync(recursive: true);
  });

  String read(String path) => File('${root.path}/$path').readAsStringSync();

  Future<void> install(List<String> args) {
    return GrpcInstallCommand(root: root, runner: runner).run(args);
  }

  /// every file of the app and its text
  Map<String, String> snapshot() {
    Map<String, String> files = <String, String>{};
    for (FileSystemEntity f in root.listSync(recursive: true)) {
      if (f is File) files[f.path] = f.readAsStringSync();
    }
    return files;
  }

  test('adds the packages, the sample proto and the router', () async {
    await install(<String>[]);
    expect(exitCode, 0);
    expect(runner.calls, <String>[
      'pub add dox_grpc',
      'pub add grpc',
      'pub add protobuf',
    ]);
    String proto = read('protos/greeter.proto');
    expect(proto, contains('protoc --dart_out=grpc:lib/app/grpc'));
    expect(proto, contains('syntax = "proto3";'));
    expect(proto, contains('package greeter;'));
    expect(proto, contains('service Greeter'));
    expect(
      proto,
      contains('rpc SayHello (HelloRequest) returns (HelloReply);'),
    );
    String router = read('lib/routes/grpc.dart');
    expect(router, contains('class GrpcRouter extends Router'));
    expect(router, contains('Grpc.register(HealthService());'));
    expect(router, isNot(contains('prefix =>')));
    expect(router, isNot(contains('Route.middleware(')));
  });

  test('adds APP_HTTP2 to .env and .env.example', () async {
    await install(<String>[]);
    expect(read('.env'), 'APP_NAME=dox\nAPP_HTTP2=true\n');
    expect(read('.env.example'), 'APP_NAME=dox\nAPP_HTTP2=true\n');
  });

  test('keeps an APP_HTTP2 that is there', () async {
    File('${root.path}/.env').writeAsStringSync('APP_HTTP2=false\n');
    await install(<String>[]);
    expect(read('.env'), 'APP_HTTP2=false\n');
    expect(read('.env.example'), 'APP_NAME=dox\nAPP_HTTP2=true\n');
  });

  test('a second run changes nothing', () async {
    await install(<String>[]);
    File('${root.path}/lib/routes/grpc.dart').writeAsStringSync('// mine {');
    File('${root.path}/protos/greeter.proto').writeAsStringSync('// mine');
    Map<String, String> before = snapshot();
    await install(<String>[]);
    expect(exitCode, 0);
    expect(snapshot(), before);
    expect(RegExp('APP_HTTP2').allMatches(read('.env')).length, 1);
  });

  test('prints the summary and the next steps', () async {
    List<String> out = <String>[];
    await runZoned(
      () => install(<String>[]),
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) =>
            out.add(line),
      ),
    );
    String text = out.join('\n');
    expect(text, contains('created  protos/greeter.proto'));
    expect(text, contains('created  lib/routes/grpc.dart'));
    expect(text, contains('added    APP_HTTP2 to .env.example, .env'));
    expect(text, contains('Next steps:'));
    expect(text, contains('http2: true'));
    expect(text, contains('GreeterServiceBase'));
  });

  test('any option stops with exit code 1 and writes nothing', () async {
    for (List<String> args in <List<String>>[
      <String>['--x'],
      <String>['x'],
      <String>['--x='],
    ]) {
      Map<String, String> before = snapshot();
      await install(args);
      expect(exitCode, 1, reason: '$args');
      expect(runner.calls, isEmpty, reason: '$args');
      expect(snapshot(), before, reason: '$args');
      exitCode = 0;
    }
  });

  test('the commands list has grpc:install', () {
    expect(commands.map((Command c) => c.name), <String>['grpc:install']);
  });

  test('the router template compiles with dox_core and dox_grpc', () async {
    Directory pkg = Directory.systemTemp.createTempSync('dox_grpc_router_');
    addTearDown(() => pkg.deleteSync(recursive: true));
    Directory lib = Directory('${pkg.path}/lib')..createSync();
    File('${lib.path}/grpc.dart')
        .writeAsStringSync(GrpcInstallCommand.grpcRouter);
    File('${pkg.path}/analysis_options.yaml')
        .writeAsStringSync('include: package:lints/recommended.yaml\n');
    File('${pkg.path}/pubspec.yaml').writeAsStringSync('''
name: router_check
environment:
  sdk: ^3.13.0
dependencies:
  dox_core: any
  dox_grpc:
    path: ${Directory.current.path}
dev_dependencies:
  lints: any
''');
    File('${Directory.current.path}/pubspec_overrides.yaml')
        .copySync('${pkg.path}/pubspec_overrides.yaml');
    ProcessResult get = Process.runSync('dart', <String>[
      'pub',
      'get',
      '--offline',
    ], workingDirectory: pkg.path);
    expect(get.exitCode, 0, reason: '${get.stdout}${get.stderr}');
    ProcessResult result = Process.runSync('dart', <String>[
      'analyze',
      '--fatal-infos',
    ], workingDirectory: pkg.path);
    expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
