import 'package:blue_bird_cli/src/commands/commands.dart';
import 'package:blue_bird_cli/src/utils/utils.dart';
import 'package:mason/mason.dart';

class BlueBirdMasonGenerator {
  const BlueBirdMasonGenerator({
    required Logger logger,
    MasonGeneratorFromBundle? generatorFromBundle,
    MasonGeneratorFromBrick? generatorFromBrick,
  })  : _logger = logger,
        _generatorFromBundle = generatorFromBundle ?? MasonGenerator.fromBundle,
        _generatorFromBrick = generatorFromBrick ?? MasonGenerator.fromBrick;

  final Logger _logger;
  final MasonGeneratorFromBundle _generatorFromBundle;
  final MasonGeneratorFromBrick _generatorFromBrick;

  Future<void> generate({
    required Template template,
    Map<String, dynamic> vars = const {},
    required DirectoryGeneratorTarget target,
  }) async {
    var args = vars;

    final generator = await getGeneratorForTemplate(template);

    await generator.hooks.preGen(vars: args, onVarsChanged: (v) => args = v);

    final files = await generator.generate(target, vars: vars, logger: _logger);

    _logger
        .progress('Bootstrapping')
        .complete('Generated ${files.length} file(s)');
  }

  Future<MasonGenerator> getGeneratorForTemplate(Template template) async {
    try {
      final brick = Brick.version(
        name: template.bundle.name,
        version: '^${template.bundle.version}',
      );
      _logger.detail(
        '''Building generator from brick: ${brick.name} ${brick.location.version}''',
      );
      return await _generatorFromBrick(brick);
    } catch (_) {
      _logger.detail('Building generator from brick failed: $_');
    }
    _logger.detail(
      '''Building generator from bundle ${template.bundle.name} ${template.bundle.version}''',
    );
    return _generatorFromBundle(template.bundle);
  }
}
