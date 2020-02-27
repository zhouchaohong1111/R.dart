import 'dart:io';

import 'generated_model.dart';
import 'generator_utils.dart';

void main(List<String> arguments) async {
  //生成动画对应的字符串
  var model = generateAnimations(animationFolderName);
  writeContentToFile(model.resources, model.headers, "GenAnimations",
      "lib/generated/gen_animations.dart");
}

GeneratedModel generateAnimations(String animationFolderName) {
  var resource = <String>[];
  var headers = <String>[];

  //自动处理animations文件夹，这个不从配置里生成，直接从子文件夹生成
  var animationDir = new Directory(animationFolderName);
  if (animationDir.existsSync()) {
    var list = animationDir.listSync(recursive: false);

    resource.add("// Generated Animations ");
    for (var file in list) {
      if (new File(file.path).statSync().type ==
          FileSystemEntityType.directory) {
        print("folder: $file");
        var path = file.path;
        var varName = nameFromPathNoAssets(file);
        var markdownPath = path.replaceAll("_", "\\_");
        resource.add('/// $markdownPath');
        resource.add("static final String $varName = '${file.path}';");
      }
    }
    resource.add("");
  }

  return GeneratedModel(headers, resource);
}
