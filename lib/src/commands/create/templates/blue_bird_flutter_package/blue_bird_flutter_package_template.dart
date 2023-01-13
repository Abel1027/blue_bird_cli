import 'package:blue_bird_cli/src/commands/create/templates/templates.dart';
import 'package:blue_bird_cli/src/utils/utils.dart';
import 'package:mason/mason.dart';
import 'package:universal_io/io.dart';

/// {@template flutter_package_template}
/// A Flutter package template.
/// {@endtemplate}
class FlutterPackageTemplate extends Template {
  /// {@macro flutter_package_template}
  FlutterPackageTemplate()
      : super(
          name: 'flutter_package',
          bundle: blueBirdFlutterPackageBundle,
          help: 'Generate a Blue Bird Flutter package.',
        );

  @override
  Future<void> onGenerateComplete(
    Logger logger,
    Directory outputDir,
    BlueBirdMasonGenerator blueBirdMasonGenerator,
  ) async {
    await installFlutterPackages(logger, outputDir);
    await applyDartFixes(logger, outputDir);
    _logSummary(logger);
  }

  void _logSummary(Logger logger) {
    logger
      ..info('\n')
      ..created(
        'You have set up a Blue Bird Flutter package... 🐣',
      )
      ..info('\n');
  }
}
