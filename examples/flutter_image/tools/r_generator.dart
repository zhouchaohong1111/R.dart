import 'animation_generator.dart';
import 'asset_generator.dart';
import 'color_generator.dart';
import 'generated_model.dart';
import 'generator_utils.dart';

void main(List<String> arguments) async {
  print(arguments);
  var isRunServer = arguments.length < 1 ||
      arguments[0] == "true"; //default, start image preview server
  print("isRunServer : $isRunServer");

  var model = GeneratedModel([], []);
  model.append(generateColors("res/color/colors.json"));
  model.append(generateAnimations(animationFolderName));

  List<String> excludes = List<String>();
  excludes.add(animationFolderName); //exclude the animation folder
  model.append(generateAssets(excludes));
  writeContentToFile(
      model.resources, model.headers, "R", "lib/generated/r.dart");
}
