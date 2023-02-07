import 'package:blue_bird_cli/src/cli/cli.dart';
import 'package:mason/mason.dart';
import 'package:universal_io/io.dart';

/// Runs `flutter packages get` in the [outputDir].
Future<void> installFlutterPackages(
  Logger logger,
  Directory outputDir, {
  bool recursive = false,
}) async {
  final isFlutterInstalled = await Flutter.installed(logger: logger);
  if (isFlutterInstalled) {
    await Flutter.packagesGet(
      cwd: outputDir.path,
      recursive: recursive,
      logger: logger,
    );
  }
}

/// Runs `dart fix --apply` in the [outputDir].
Future<void> applyDartFixes(
  Logger logger,
  Directory outputDir, {
  bool recursive = false,
}) async {
  final isDartInstalled = await Dart.installed(logger: logger);
  if (isDartInstalled) {
    final applyFixesProgress = logger.progress(
      'Running "dart fix --apply" in ${outputDir.path}',
    );
    await Dart.applyFixes(
      cwd: outputDir.path,
      recursive: recursive,
      logger: logger,
    );
    applyFixesProgress.complete();
  }
}

/// Runs `flutter gen-l10n` in the [l10nDir].
Future<void> generateL10n(
  Logger logger,
  Directory l10nDir,
) async {
  final isFlutterInstalled = await Flutter.installed(logger: logger);
  if (isFlutterInstalled) {
    final generateL10nProgress = logger.progress(
      'Running "flutter gen-l10n" in ${l10nDir.path}',
    );
    await Flutter.l10nGen(cwd: l10nDir.path, logger: logger);
    generateL10nProgress.complete();
  }
}

/// Activate Melos CLI.
Future<void> activateMelos(Logger logger) async {
  final isDartInstalled = await Dart.installed(logger: logger);
  if (isDartInstalled) {
    final activateMelosProgress = logger.progress(
      'Activating Melos CLI',
    );
    await Dart.activate(
      logger: logger,
      package: 'melos',
    );
    activateMelosProgress.complete();
  }
}
