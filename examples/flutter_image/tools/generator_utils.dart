import 'dart:io';

//the resoures folders
var assetsFolderName = "assets";
var animationFolderName = "assets/animation";
var preview_server_port = 2227;

bool isImage(String subType) {
  RegExp exp = new RegExp(r"\.?(jpeg|jpg|png|gif|webp)");
  return exp.hasMatch(subType.toLowerCase());
}

/// abc_def to abcDef
String underlineToCamel(String varName) {
  print(varName);
  var pos = 0;
  String char;
  while (true) {
    pos = varName.indexOf('_', pos);
    if (pos == -1) break;
    char = varName.substring(pos + 1, pos + 2);
    varName = varName.replaceFirst('_$char', '_${char.toUpperCase()}');
    pos++;
  }
  varName = varName.replaceAll('_', '');
  return varName;
}

void writeContentToFile(List<String> resource, List<String> headers,
    String className, String filename) {
  var r = new File(filename);
  if (r.existsSync()) {
    r.deleteSync();
  }
  r.createSync(recursive: true);

  var content = '';
  for (var line in headers) {
    content = '$content$line\n';
  }

  content = '$content class $className {\n';
  for (var line in resource) {
    content = '$content  $line\n';
  }
  content = '$content}\n';
  r.writeAsStringSync(content);
}

String nameFromPathNoAssets(FileSystemEntity file) {
  var removeHeadPath = file.uri.pathSegments;
  if (removeHeadPath.length > 1 && removeHeadPath[0] == assetsFolderName) {
    removeHeadPath = file.uri.pathSegments.sublist(1);
  }

  var noAssetsPath = removeHeadPath.join("/");
  if (noAssetsPath.endsWith("/")) {
    //get rid of the end of "/"
    noAssetsPath = noAssetsPath.substring(0, noAssetsPath.length - 1);
  }
  noAssetsPath = noAssetsPath.replaceAll('-', "_");

  var varName = noAssetsPath
      .replaceAll('/', '_')
      .replaceAll(new RegExp(r'\.\w+'), '')
      .toLowerCase(); //get rid of subType of file

  varName = underlineToCamel(varName);
  return varName;
}
