
import 'package:yaml/yaml.dart';

import 'utils/utils.dart';

class Config {
  String pubspecFilename;
  List<String> ignoreAssets = [];
//  String intlFilename;
//  List<CustomAssetType> assetClasses = [];

  Config();

  factory Config.parsePubspecConfig(YamlMap yaml) {
    final arguments = Config()..pubspecFilename = 'pubspec.yaml';

    final rFlutterConfig = safeCast<YamlMap>(yaml["r_dart"]);
    if (rFlutterConfig == null) {
      return arguments;
    }

    final ignoreRaw = safeCast<YamlList>(rFlutterConfig['ignore']);
    arguments.ignoreAssets = ignoreRaw
            ?.map((x) => safeCast<String>(x))
            ?.where((it) => it != null)
            ?.toList() ??
        [];

    return arguments;
  }
}
