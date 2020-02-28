import 'dart:io';

import 'generated_model.dart';
import 'generator_utils.dart';

void main(List<String> arguments) async {
  //生成动画对应的字符串
  var model = generateImages(imageFolderName);
  writeContentToFile(model.resources, model.headers, "GenImages",
      "lib/generated/gen_images.dart");
}

GeneratedModel generateImages(String imageFolderName) {
  var resource = <String>[];
  var headers = <String>[];

  headers.add("import 'package:flutter/widgets.dart';");
  //自动处理image文件夹，这个不从配置里生成，直接从子文件夹生成
  var imageDir = new Directory(imageFolderName);
  if (imageDir.existsSync()) {
    var list = imageDir.listSync(recursive: false);

    resource.add("// Generated Images ");
    for (var file in list) {
      if (new File(file.path).statSync().type ==
          FileSystemEntityType.file) {
        print("folder: $file");
        var path = file.path;
        var varName = nameFromPathNoAssets(file);
        var markdownPath = path.replaceAll("_", "\\_");
        resource.add('/// $markdownPath');
        resource.add("static AssetImage get $varName => const AssetImage('${file.path}');");
      }
    }
    resource.add("");
  }

  return GeneratedModel(headers, resource);
}
