// ignore_for_file: no_adjacent_strings_in_list

import 'dart:async';

import 'package:blue_bird_cli/src/cli/cli.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

const _pubspec = '''
name: example
environment:
  sdk: ">=2.13.0 <3.0.0"

dev_dependencies:
  test: any''';

const _unreachableGitUrlPubspec = '''
name: example
environment:
  sdk: ">=2.13.0 <3.0.0"

dev_dependencies:
  very_good_analysis:
    git:
      url: https://github.com/verygoodopensource/_very_good_analysis''';

class _TestProcess {
  Future<ProcessResult> run(
    String command,
    List<String> args, {
    bool runInShell = false,
    String? workingDirectory,
  }) {
    throw UnimplementedError();
  }
}

class _MockProcess extends Mock implements _TestProcess {}

class _MockProcessResult extends Mock implements ProcessResult {}

class _MockLogger extends Mock implements Logger {}

class _MockProgress extends Mock implements Progress {}

class _FakeGeneratorTarget extends Fake implements GeneratorTarget {}

void main() {
  group('Flutter', () {
    late ProcessResult processResult;
    late _TestProcess process;
    late Logger logger;
    late Progress progress;

    setUpAll(() {
      registerFallbackValue(_FakeGeneratorTarget());
      registerFallbackValue(FileConflictResolution.prompt);
    });

    setUp(() {
      logger = _MockLogger();
      progress = _MockProgress();
      when(() => logger.progress(any())).thenReturn(progress);

      processResult = _MockProcessResult();
      process = _MockProcess();
      when(() => processResult.exitCode).thenReturn(ExitCode.success.code);
      when(
        () => process.run(
          any(),
          any(),
          runInShell: any(named: 'runInShell'),
          workingDirectory: any(named: 'workingDirectory'),
        ),
      ).thenAnswer((_) async => processResult);
    });

    group('.packagesGet', () {
      test('throws when there is no pubspec.yaml', () {
        ProcessOverrides.runZoned(
          () => expectLater(
            Flutter.packagesGet(cwd: Directory.systemTemp.path, logger: logger),
            throwsA(isA<PubspecNotFound>()),
          ),
          runProcess: process.run,
        );
      });

      test('throws when process fails', () {
        final flutterProcessResult = _MockProcessResult();
        when(
          () => flutterProcessResult.exitCode,
        ).thenReturn(ExitCode.software.code);
        when(
          () => process.run(
            'flutter',
            any(),
            runInShell: any(named: 'runInShell'),
            workingDirectory: any(named: 'workingDirectory'),
          ),
        ).thenAnswer((_) async => flutterProcessResult);

        ProcessOverrides.runZoned(
          () => expectLater(
            Flutter.packagesGet(cwd: Directory.systemTemp.path, logger: logger),
            throwsException,
          ),
          runProcess: process.run,
        );
      });

      test('throws when there is an unreachable git url', () {
        final directory = Directory.systemTemp.createTempSync();
        File(p.join(directory.path, 'pubspec.yaml'))
            .writeAsStringSync(_unreachableGitUrlPubspec);

        final gitProcessResult = _MockProcessResult();
        when(
          () => gitProcessResult.exitCode,
        ).thenReturn(ExitCode.software.code);
        when(
          () => process.run(
            'git',
            any(that: contains('ls-remote')),
            runInShell: any(named: 'runInShell'),
            workingDirectory: any(named: 'workingDirectory'),
          ),
        ).thenAnswer((_) async => gitProcessResult);

        ProcessOverrides.runZoned(
          () => expectLater(
            () => Flutter.packagesGet(cwd: directory.path, logger: logger),
            throwsA(isA<UnreachableGitDependency>()),
          ),
          runProcess: process.run,
        );
      });

      test('completes when the process succeeds', () {
        ProcessOverrides.runZoned(
          () => expectLater(Flutter.packagesGet(logger: logger), completes),
          runProcess: process.run,
        );
      });

      test('throws when there is no pubspec.yaml (recursive)', () {
        ProcessOverrides.runZoned(
          () => expectLater(
            Flutter.packagesGet(
              cwd: Directory.systemTemp.createTempSync().path,
              recursive: true,
              logger: logger,
            ),
            throwsA(isA<PubspecNotFound>()),
          ),
          runProcess: process.run,
        );
      });

      test('completes when there is a pubspec.yaml (recursive)', () {
        final directory = Directory.systemTemp.createTempSync();
        final nestedDirectory = Directory(p.join(directory.path, 'test'))
          ..createSync();
        File(p.join(nestedDirectory.path, 'pubspec.yaml'))
            .writeAsStringSync(_pubspec);

        ProcessOverrides.runZoned(
          () => expectLater(
            Flutter.packagesGet(
              cwd: directory.path,
              recursive: true,
              logger: logger,
            ),
            completes,
          ),
          runProcess: process.run,
        );
      });
    });

    group('.pubGet', () {
      test('throws when there is no pubspec.yaml', () {
        ProcessOverrides.runZoned(
          () => expectLater(
            Flutter.pubGet(cwd: Directory.systemTemp.path, logger: logger),
            throwsA(isA<PubspecNotFound>()),
          ),
          runProcess: process.run,
        );
      });

      test('throws when process fails', () {
        final flutterProcessResult = _MockProcessResult();
        when(
          () => flutterProcessResult.exitCode,
        ).thenReturn(ExitCode.software.code);
        when(
          () => process.run(
            'flutter',
            any(),
            runInShell: any(named: 'runInShell'),
            workingDirectory: any(named: 'workingDirectory'),
          ),
        ).thenAnswer((_) async => flutterProcessResult);
        ProcessOverrides.runZoned(
          () => expectLater(
            Flutter.pubGet(cwd: Directory.systemTemp.path, logger: logger),
            throwsException,
          ),
          runProcess: process.run,
        );
      });

      test('completes when the process succeeds', () {
        ProcessOverrides.runZoned(
          () => expectLater(Flutter.pubGet(logger: logger), completes),
          runProcess: process.run,
        );
      });

      test('completes when the process succeeds (recursive)', () {
        ProcessOverrides.runZoned(
          () => expectLater(
            Flutter.pubGet(recursive: true, logger: logger),
            completes,
          ),
          runProcess: process.run,
        );
      });

      test('throws when process fails', () {
        when(() => processResult.exitCode).thenReturn(ExitCode.software.code);
        ProcessOverrides.runZoned(
          () => expectLater(Flutter.pubGet(logger: logger), throwsException),
          runProcess: process.run,
        );
      });

      test('throws when process fails (recursive)', () {
        when(() => processResult.exitCode).thenReturn(ExitCode.software.code);
        ProcessOverrides.runZoned(
          () => expectLater(
            Flutter.pubGet(recursive: true, logger: logger),
            throwsException,
          ),
          runProcess: process.run,
        );
      });
    });
  });
}
