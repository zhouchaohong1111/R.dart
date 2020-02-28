import 'dart:async';

import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

import 'src/arguments.dart';
import 'src/generator/generator.dart';
import 'src/utils/utils.dart';

class AssetsBuilder extends Builder {
  /// This is needed to let build system know that we depend on given file
  Future<void> check(BuildStep buildStep, String filename) async {
    if (filename == null) {
      return;
    }
    await buildStep.canRead(AssetId(buildStep.inputId.package, filename));
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    log.info('processing: ${buildStep.inputId}');

    final input = buildStep.inputId;

    final output = AssetId(input.package, 'lib/generated/r.dart');

    final configId = AssetId(input.package, 'pubspec.yaml');

    final configRaw = safeCast<YamlMap>(loadYaml(await buildStep.readAsString(configId)));
    final config = Config.parsePubspecConfig(configRaw ?? YamlMap());

    await check(buildStep, config.pubspecFilename);

    final generated = generateFile(config);
    await buildStep.writeAsString(output, generated);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r"$lib$": ["generated/R.dart"],
      };
}


Builder assetsGenerator(BuilderOptions builderOptions) {
  log.info('creating AssetsGenerator');
  return AssetsBuilder();
}
