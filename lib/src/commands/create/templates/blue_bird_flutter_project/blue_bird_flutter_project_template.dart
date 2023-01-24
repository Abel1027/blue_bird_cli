import 'package:blue_bird_cli/src/commands/create/templates/templates.dart';
import 'package:blue_bird_cli/src/utils/utils.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

/// {@template flutter_project_template}
/// A Flutter project template.
/// {@endtemplate}
class FlutterProjectTemplate extends Template {
  /// {@macro flutter_project_template}
  FlutterProjectTemplate()
      : super(
          name: 'flutter_project',
          bundle: blueBirdFlutterProjectBundle,
          help: 'Generate a Blue Bird Flutter project.',
        );

  @override
  Future<void> onGenerateComplete(
    Logger logger,
    Directory outputDir,
    BlueBirdMasonGenerator blueBirdMasonGenerator,
  ) async {
    await _createExamplePackage(blueBirdMasonGenerator, outputDir);
    await installFlutterPackages(logger, outputDir, recursive: true);
    final l10nPath = path.join(outputDir.path, 'core', 'internationalization');
    await generateL10n(logger, Directory(l10nPath));
    await applyDartFixes(logger, outputDir);
    _logSummary(logger);
  }

  void _logSummary(Logger logger) {
    logger
      ..info('\n')
      ..created(
        'You have set up a Blue Bird Flutter project... 🐣',
      )
      ..info('\n');
  }

  Future<void> _createExamplePackage(
    BlueBirdMasonGenerator blueBirdMasonGenerator,
    Directory projectDir,
  ) async {
    final template = FlutterPackageTemplate();
    final vars = {'project_name': 'feat_example', 'in_project': 'true'};
    final directory = Directory(path.join(projectDir.path, 'features'));
    final target = DirectoryGeneratorTarget(directory);

    await blueBirdMasonGenerator.generate(
      template: template,
      vars: vars,
      target: target,
    );
  }
}
