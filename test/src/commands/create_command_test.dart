@Timeout(Duration(minutes: 5))

import 'dart:io';

import 'package:args/args.dart';
import 'package:blue_bird_cli/src/commands/commands.dart';
import 'package:blue_bird_cli/src/utils/utils.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
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

class MockMasonGenerator extends Mock implements MasonGenerator {}

class MockGeneratorHooks extends Mock implements GeneratorHooks {}

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
    --application-id                     The bundle identifier on iOS or application id on Android.
                                         (defaults to "com.example.bluebird.appid")
    --in-project                         Include the new project within an existing one with all dependencies imported
                                         (defaults to "false")

Run "blue_bird help" to see global options.'''
];

String pubspec(String name) => '''
name: $name
environment:
  sdk: ">=2.13.0 <3.0.0"
''';

const intlPubspec = '''

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.17.0
''';

const l10n = '''
synthetic-package: false
arb-dir: lib/src/l10n
template-arb-file: intl_en.arb
output-dir: lib/src/l10n/generated/
output-localization-file: app_localizations.dart
output-class: S
''';

const intlArb = '''
{
    "example": "Example"
}
''';

void main() {
  group('create', () {
    late Progress progress;
    late List<String> progressLogs;
    late Logger logger;

    final generatedProjectFiles = List.filled(
      133,
      const GeneratedFile.created(path: ''),
    );
    final generatedFlutterPackageFiles = List.filled(
      19,
      const GeneratedFile.created(path: ''),
    );

    setUpAll(() {
      registerFallbackValue(FakeTemplate());
      registerFallbackValue(FakeDirectoryGeneratorTarget());
      registerFallbackValue(FakeDirectory());
    });

    setUp(() {
      progress = MockProgress();
      progressLogs = <String>[];
      logger = MockLogger();

      when(() => progress.complete(any())).thenAnswer((_) {
        final message = _.positionalArguments.elementAt(0) as String?;
        if (message != null) progressLogs.add(message);
      });
      when(() => logger.progress(any())).thenReturn(progress);
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
        final hooks = MockGeneratorHooks();
        final generator = MockMasonGenerator();
        final command = CreateCommand(
          logger: logger,
          blueBirdMasonGenerator: BlueBirdMasonGenerator(
            logger: logger,
            generatorFromBundle: (_) async => generator,
          ),
        )..argResultOverrides = argResults;
        when(() => argResults['output-directory'] as String?)
            .thenReturn('.tmp');
        when(() => argResults['application-id'] as String?)
            .thenReturn('blue.bird.org.my_flutter_project');
        when(() => argResults.rest).thenReturn(['my_flutter_project']);
        when(() => generator.hooks).thenReturn(hooks);
        when(
          () => hooks.preGen(
            vars: any(named: 'vars'),
            onVarsChanged: any(named: 'onVarsChanged'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => generator.generate(
            any(),
            vars: any(named: 'vars'),
            logger: any(named: 'logger'),
          ),
        ).thenAnswer((_) async {
          final intlFile = File(
            p.join(
              '.tmp',
              'my_flutter_project',
              'core',
              'internationalization',
              'pubspec.yaml',
            ),
          );

          final packageFiles = [
            File(
              p.join(
                '.tmp',
                'my_flutter_project',
                'pubspec.yaml',
              ),
            ),
            File(
              p.join(
                '.tmp',
                'my_flutter_project',
                'core',
                'components',
                'pubspec.yaml',
              ),
            ),
            File(
              p.join(
                '.tmp',
                'my_flutter_project',
                'core',
                'dependencies',
                'pubspec.yaml',
              ),
            ),
            File(
              p.join(
                '.tmp',
                'my_flutter_project',
                'core',
                'di',
                'pubspec.yaml',
              ),
            ),
            intlFile,
            File(
              p.join(
                '.tmp',
                'my_flutter_project',
                'core',
                'network',
                'pubspec.yaml',
              ),
            ),
            File(
              p.join(
                '.tmp',
                'my_flutter_project',
                'core',
                'routes',
                'pubspec.yaml',
              ),
            ),
            File(
              p.join(
                '.tmp',
                'my_flutter_project',
                'core',
                'theme',
                'pubspec.yaml',
              ),
            ),
            File(
              p.join(
                '.tmp',
                'my_flutter_project',
                'features',
                'feat_example',
                'pubspec.yaml',
              ),
            ),
          ];

          for (final file in packageFiles) {
            file
              ..createSync(recursive: true)
              ..writeAsStringSync(pubspec(p.basename(p.dirname(file.path))));
          }

          // append intl dependencies to pubspec
          intlFile.writeAsStringSync(intlPubspec, mode: FileMode.append);

          // create l10n config file
          File(
            p.join(
              '.tmp',
              'my_flutter_project',
              'core',
              'internationalization',
              'l10n.yaml',
            ),
          )
            ..createSync(recursive: true)
            ..writeAsStringSync(l10n);

          // create arb file
          File(
            p.join(
              '.tmp',
              'my_flutter_project',
              'core',
              'internationalization',
              'lib',
              'src',
              'l10n',
              'intl_en.arb',
            ),
          )
            ..createSync(recursive: true)
            ..writeAsStringSync(intlArb);

          return generatedProjectFiles;
        });

        final result = await command.run();
        expect(result, equals(ExitCode.success.code));
        verify(() => logger.progress('Bootstrapping')).called(2);
        expect(
          progressLogs,
          equals(
            [
              'Generated ${generatedProjectFiles.length} file(s)',
              'Generated ${generatedProjectFiles.length} file(s)'
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
        final hooks = MockGeneratorHooks();
        final generator = MockMasonGenerator();
        final command = CreateCommand(
          logger: logger,
          blueBirdMasonGenerator: BlueBirdMasonGenerator(
            logger: logger,
            generatorFromBundle: (_) async => generator,
          ),
        )..argResultOverrides = argResults;
        when(() => argResults['output-directory'] as String?)
            .thenReturn('.tmp');
        when(() => argResults['template'] as String?)
            .thenReturn('flutter_package');
        when(() => argResults.rest).thenReturn(['my_flutter_package']);
        when(() => generator.hooks).thenReturn(hooks);
        when(
          () => hooks.preGen(
            vars: any(named: 'vars'),
            onVarsChanged: any(named: 'onVarsChanged'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => generator.generate(
            any(),
            vars: any(named: 'vars'),
            logger: any(named: 'logger'),
          ),
        ).thenAnswer((_) async {
          File(p.join('.tmp', 'my_flutter_package', 'pubspec.yaml'))
            ..createSync(recursive: true)
            ..writeAsStringSync(pubspec('my_flutter_package'));
          return generatedFlutterPackageFiles;
        });

        final result = await command.run();
        expect(result, equals(ExitCode.success.code));
        verify(() => logger.progress('Bootstrapping')).called(1);
        expect(
          progressLogs,
          equals(
            ['Generated ${generatedFlutterPackageFiles.length} file(s)'],
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
