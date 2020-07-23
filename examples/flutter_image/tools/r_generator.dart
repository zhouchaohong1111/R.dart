import 'animation_generator.dart';
import 'asset_generator.dart';
import 'color_generator.dart';
import 'generated_model.dart';
import 'generator_utils.dart';
import 'image_generator.dart';

void main(List<String> arguments) async {
  var model = GeneratedModel([], []);
  model.append(generateColors("res/color/colors.json"));
  model.append(generateAnimations(animationFolderName));
  model.append(generateImages(imageFolderName));

  List<String> excludes = List<String>();
  excludes.add(animationFolderName); //exclude the animation folder
  excludes.add(imageFolderName); //exclude the image folder
  model.append(generateAssets(excludes));
  writeContentToFile(
      model.resources, model.headers, "R", "lib/generated/r.dart");
}
