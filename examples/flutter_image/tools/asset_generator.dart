// Copyright 2018 haikuotiankong All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

//idea and origin code from：https://github.com/flutter-dev/asset_generator
// modify for easy use

//use: just run this script as ` dart ./tools/asset_generator.dart ` at the project path.

// configuration:
// pubspec.yaml like below

//

//    # use for asset_generator.dart 自动生成 r.dart
//    # assets begin

//  assets:
//    - assets/image/
//    - assets/animations/
//    - assets/video/

//    # assets end

import 'dart:io';

import 'generated_model.dart';
import 'generator_utils.dart';

var preview_server_port = 2227;

void main(List<String> arguments) async {
  print(arguments);
  var isRunServer = arguments.length < 1 || arguments[0] == "true"; //默认启动预览服务器
  print("isRunServer : $isRunServer");

  //生成动画对应的字符串
  List<String> excludes = List<String>();
  excludes.add(animationFolderName);
  var model = generateAssets(excludes);
  writeContentToFile(model.resources, model.headers, "GenAssets",
      "lib/generated/gen_assets.dart");

  if (!isRunServer) {
    print("不需启动预览服务器，退出");
    return;
  } else {
    runImageServer(preview_server_port);
  }
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

void runImageServer(int port) async {
  var ser;
  try {
    ser = await HttpServer.bind('127.0.0.1', port);
    print('成功启动图片预览服务器于本机<$preview_server_port>端口');
    ser.listen(
      (req) {
        var index = req.uri.path.lastIndexOf('.');
        var subType = req.uri.path.substring(index);
        var contentType = new ContentType('image', subType);
        req.response
          ..headers.contentType = contentType
          ..add(new File('./${req.uri.path}').readAsBytesSync())
          ..close();
      },
    );
  } catch (e) {
    print('图片预览服务器已启动或端口被占用');
  }
}
