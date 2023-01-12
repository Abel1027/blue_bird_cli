import 'package:blue_bird_cli/src/commands/create/templates/templates.dart';
import 'package:blue_bird_cli/src/utils/utils.dart';
import 'package:mason/mason.dart';
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
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    await installFlutterPackages(logger, outputDir);
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
}
