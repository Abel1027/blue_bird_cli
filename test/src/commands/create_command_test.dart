@Timeout(Duration(minutes: 5))

import 'dart:io';

import 'package:args/args.dart';
import 'package:blue_bird_cli/src/commands/commands.dart';
import 'package:blue_bird_cli/src/utils/utils.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

class FakeProcessResult extends Fake implements ProcessResult {}

class FakeTemplate extends Fake implements Template {}

class FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

class FakeDirectory extends Fake implements Directory {}

class MockArgResults extends Mock implements ArgResults {}

class MockLogger extends Mock implements Logger {}

class MockProgress extends Mock implements Progress {}

class MockPubUpdater extends Mock implements PubUpdater {}

class MockBlueBirdMasonGenerator extends Mock
    implements BlueBirdMasonGenerator {}

class MockTemplate extends Mock implements Template {}

const expectedUsage = [
  '''
Creates a new blue bird project in the specified directory.

Usage: blue_bird create <project name>
-h, --help                               Print this usage information.
-o, --output-directory                   The desired output directory when creating a new project.
    --desc                               The description for this new project.
                                         (defaults to "Blue Bird CLI.")
    --org-name                           The organization for this new project.
                                         (defaults to "com.example.bluebird")
-t, --template                           The template used to generate this new project.

          [flutter_package]              Generate a Blue Bird Flutter package.
          [flutter_project] (default)    Generate a Blue Bird Flutter project.

    --android                            The plugin supports the Android platform.
                                         (defaults to "true")
    --ios                                The plugin supports the iOS platform.
                                         (defaults to "true")
    --web                                The plugin supports the Web platform.
                                         (defaults to "true")
    --linux                              The plugin supports the Linux platform.
                                         (defaults to "true")
    --macos                              The plugin supports the macOS platform.
                                         (defaults to "true")
    --windows                            The plugin supports the Windows platform.
                                         (defaults to "true")
    --application-id                     The bundle identifier on iOS or application id on Android. (defaults to <org-name>.<project-name>)
    --in-project                         Include the new project within an existing one with all dependencies imported
                                         (defaults to "false")

Run "blue_bird help" to see global options.'''
];

void main() {
  group('create', () {
    late Progress progress;
    late List<String> progressLogs;
    late Logger logger;

    const generatedProjectFiles = 133;
    const generatedFlutterPackageFiles = 19;

    setUpAll(() {
      registerFallbackValue(FakeTemplate());
      registerFallbackValue(FakeDirectoryGeneratorTarget());
      registerFallbackValue(FakeDirectory());
    });

    setUp(() {
      progress = MockProgress();
      progressLogs = <String>[];
      //   pubUpdater = MockPubUpdater();
      logger = MockLogger();
      //   commandRunner = BlueBirdCliCommandRunner(
      //     logger: logger,
      //     pubUpdater: pubUpdater,
      //   );

      //   when(
      //     () => pubUpdater.getLatestVersion(any()),
      //   ).thenAnswer((_) async => packageVersion);
      when(() => progress.complete(any())).thenAnswer((_) {
        final message = _.positionalArguments.elementAt(0) as String?;
        if (message != null) progressLogs.add(message);
      });
      when(() => logger.progress(any())).thenReturn(progress);
      //   when(
      //     () => pubUpdater.isUpToDate(
      //       packageName: any(named: 'packageName'),
      //       currentVersion: any(named: 'currentVersion'),
      //     ),
      //   ).thenAnswer((_) => Future.value(true));
    });

    test('can be instantiated', () {
      final command = CreateCommand(
        logger: logger,
        blueBirdMasonGenerator: BlueBirdMasonGenerator(logger: logger),
      );
      expect(command, isNotNull);
    });

    test(
      'help',
      withRunner((commandRunner, logger, pubUpdater, printLogs) async {
        final result = await commandRunner.run(['create', '--help']);
        expect(printLogs, equals(expectedUsage));
        expect(result, equals(ExitCode.success.code));

        printLogs.clear();

        final resultAbbr = await commandRunner.run(['create', '-h']);
        expect(printLogs, equals(expectedUsage));
        expect(resultAbbr, equals(ExitCode.success.code));
      }),
    );

    test(
      'throws UsageException when --project-name is missing '
      'and directory base is not a valid package name',
      withRunner((commandRunner, logger, pubUpdater, printLogs) async {
        const expectedErrorMessage = '".tmp" is not a valid package name.\n\n'
            'See https://dart.dev/tools/pub/pubspec#name for more information.';
        final result = await commandRunner.run(['create', '.tmp']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(expectedErrorMessage)).called(1);
      }),
    );

    test(
      'throws UsageException when project-name is invalid',
      withRunner((commandRunner, logger, pubUpdater, printLogs) async {
        const expectedErrorMessage = '"My App" is not a valid package name.\n\n'
            'See https://dart.dev/tools/pub/pubspec#name for more information.';
        final result = await commandRunner.run(['create', 'My App']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(expectedErrorMessage)).called(1);
      }),
    );

    test(
      'throws UsageException when multiple project names are provided',
      withRunner((commandRunner, logger, pubUpdater, printLogs) async {
        const expectedErrorMessage = 'Multiple project names specified.';
        final result = await commandRunner.run(['create', 'a', 'b']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(expectedErrorMessage)).called(1);
      }),
    );

    test(
      'completes successfully flutter_project with correct output',
      () async {
        final argResults = MockArgResults();
        final command = CreateCommand(
          logger: logger,
          blueBirdMasonGenerator: BlueBirdMasonGenerator(logger: logger),
        )..argResultOverrides = argResults;
        when(() => argResults['output-directory'] as String?)
            .thenReturn('.tmp');
        when(() => argResults['application-id'] as String?)
            .thenReturn('blue.bird.org.my_flutter_project');
        when(() => argResults.rest).thenReturn(['my_flutter_project']);

        final result = await command.run();
        expect(result, equals(ExitCode.success.code));
        verify(() => logger.progress('Bootstrapping')).called(2);
        expect(
          progressLogs,
          equals(
            [
              'Generated $generatedProjectFiles file(s)',
              'Generated $generatedFlutterPackageFiles file(s)'
            ],
          ),
        );
        verify(
          () => logger.progress(
            r'Running "flutter packages get" in .tmp\my_flutter_project',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "flutter packages get" in .tmp\my_flutter_project\core\components',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "flutter packages get" in .tmp\my_flutter_project\core\dependencies',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "flutter packages get" in .tmp\my_flutter_project\core\di',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "flutter packages get" in .tmp\my_flutter_project\core\internationalization',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "flutter packages get" in .tmp\my_flutter_project\core\network',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "flutter packages get" in .tmp\my_flutter_project\core\routes',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "flutter packages get" in .tmp\my_flutter_project\core\theme',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "flutter packages get" in .tmp\my_flutter_project\features\feat_example',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "flutter gen-l10n" in .tmp\my_flutter_project\core\internationalization',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "dart fix --apply" in .tmp\my_flutter_project',
          ),
        ).called(1);
        verify(
          () => logger.created(
            'You have set up a Blue Bird Flutter project... 🐣',
          ),
        ).called(1);
      },
    );

    test(
      'completes successfully flutter_package with correct output',
      () async {
        final argResults = MockArgResults();
        final command = CreateCommand(
          logger: logger,
          blueBirdMasonGenerator: BlueBirdMasonGenerator(logger: logger),
        )..argResultOverrides = argResults;
        when(() => argResults['output-directory'] as String?)
            .thenReturn('.tmp');
        when(() => argResults['template'] as String?)
            .thenReturn('flutter_package');
        when(() => argResults.rest).thenReturn(['my_flutter_package']);

        final result = await command.run();
        expect(result, equals(ExitCode.success.code));
        verify(() => logger.progress('Bootstrapping')).called(1);
        expect(
          progressLogs,
          equals(
            ['Generated $generatedFlutterPackageFiles file(s)'],
          ),
        );
        verify(
          () => logger.progress(
            r'Running "flutter packages get" in .tmp\my_flutter_package',
          ),
        ).called(1);
        verify(
          () => logger.progress(
            r'Running "dart fix --apply" in .tmp\my_flutter_package',
          ),
        ).called(1);
        verify(
          () => logger.created(
            'You have set up a Blue Bird Flutter package... 🐣',
          ),
        ).called(1);
      },
    );

    group('org-name', () {
      group('--org', () {
        group('invalid --org-name', () {
          String expectedErrorMessage(String orgName) =>
              '"$orgName" is not a valid org name.\n\n'
              'A valid org name has at least 2 parts separated by "."\n'
              'Each part must start with a letter and only include '
              'alphanumeric characters (A-Z, a-z, 0-9), underscores (_), '
              'and hyphens (-)\n'
              '(ex. blue.bird.org)';

          test(
            'less than 2 domains',
            withRunner((commandRunner, logger, pubUpdater, printLogs) async {
              const orgName = 'bluebird';
              final result = await commandRunner.run(
                ['create', 'my_project', '--org-name', orgName],
              );
              expect(result, equals(ExitCode.usage.code));
              verify(() => logger.err(expectedErrorMessage(orgName))).called(1);
            }),
          );
        });
      });
    });
  });
}
