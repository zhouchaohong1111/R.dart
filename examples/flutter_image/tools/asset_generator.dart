import 'dart:io';

import 'generated_model.dart';
import 'generator_utils.dart';



void main(List<String> arguments) async {
  //生成动画对应的字符串
  List<String> excludes = List<String>();
  excludes.add(animationFolderName);
  var model = generateAssets(excludes);
  writeContentToFile(model.resources, model.headers, "GenAssets",
      "lib/generated/gen_assets.dart");
}

GeneratedModel generateAssets(List<String> excluedFolders) {
  bool working = false;
  var pubSpec = new File('pubspec.yaml');
  var pubLines = pubSpec.readAsLinesSync();
  var resource = <String>[];
  var headers = <String>[];

  resource.add("// Generated Other Assets ");
  for (var line in pubLines) {
    if (line.contains('begin') &&
        line.contains('#') &&
        line.contains('assets')) {
      working = true;
    }
    if (line.contains('end') && line.contains('#') && line.contains('assets'))
      working = false;

    if (working) {
      if (line.trim().startsWith('-') && line.trim().endsWith('/')) {
        var dirPath = line.replaceAll('-', '').trim();
        if (dirPath.isEmpty) {
          continue;
        }
        var directory = new Directory(dirPath);

        //Skip all exclude folders
        var needSkip = false;
        for (var folder in excluedFolders) {
          needSkip = dirPath.startsWith(folder);
          if (needSkip) {
            break;
          }
        }
        if (needSkip) {
          continue;
        }

        if (directory.existsSync()) {
          var list = directory.listSync(
              recursive:
                  false); //no need recursive， the same as flutter framework
          for (var file in list) {
            if (new File(file.path).statSync().type ==
                FileSystemEntityType.file) {
              var path = file.path.replaceAll('\\', '/');

              var index = file.uri.path.lastIndexOf('.');
              var subType = file.uri.path.substring(index);

              if (path.contains("2.0x") ||
                  path.contains("3.0x") ||
                  path.contains("dark")) {
                continue;
              }

              print("file:$file");

              var varName = nameFromPathNoAssets(file);

              var markdownPath = path.replaceAll("_", "\\_");
              resource.add('/// $markdownPath');
              if (isImage(subType)) {
                //preview for image
                resource.add(
                    "/// ![](http://127.0.0.1:$preview_server_port/$path)");
              }

              resource.add("static final String $varName = '$path';");
              resource.add(""); //empty line, just more beautifull.
            }
          }
        } else {
          throw new FileSystemException('Directory wrong');
        }
      }
    }
  }

  return GeneratedModel(headers, resource);
}

