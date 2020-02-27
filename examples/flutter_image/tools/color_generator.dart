import 'dart:convert';
import 'dart:io';

import 'generated_model.dart';
import 'generator_utils.dart';

const colorJsonPath = "res/color/colors.json";

void main(List<String> argv) async {
  var model = generateColors(colorJsonPath);
  writeContentToFile(model.resources, model.headers, "GenColors",
      "lib/generated/gen_colors.dart");
}

GeneratedModel generateColors(String colorJsonPath) {
  var file = new File(colorJsonPath);
  String content = file.readAsStringSync();
  Map<String, dynamic> obj = json.decode(content);
  var resource = <String>[];

  var headers = <String>[];
  headers.add("import 'dart:ui';"); //need this to use Color class
  headers.add("");

  var name = nameFromPathNoAssets(file);

  obj.forEach((String key, dynamic value) {
//    print('$key : $value');
    resource.add("/// <font color=$value>$value</font>");

    var varName = underlineToCamel(key);
    resource.add("static final Color $varName = ${parseColor(value)};");
  });
  resource.add("");

  return GeneratedModel(headers, resource);
}

String parseColor(String value) {
  var newValue = value;
  if (value.startsWith("#")) {
    newValue = value.replaceFirst("#", "0x");
  }

  int hex = int.parse(newValue);
  if (newValue.length == 10) {
    //like "0x1f00ffff" include alpha
    double alpha = ((hex & 0xFF000000) >> 24) / 255.0;
    return "Color.fromRGBO(${(hex & 0xFF0000) >> 16}, ${(hex & 0x00FF00) >> 8}, ${(hex & 0x0000FF) >> 0}, $alpha)";
  } else {
    // like "0xff00ff"
    return "Color.fromRGBO(${(hex & 0xFF0000) >> 16}, ${(hex & 0x00FF00) >> 8}, ${(hex & 0x0000FF) >> 0}, 1.0)";
  }
}
