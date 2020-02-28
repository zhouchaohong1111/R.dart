import '../arguments.dart';
import 'animation_generator.dart';
import 'asset_generator.dart';
import 'color_generator.dart';
import 'generated_model.dart';
import 'generator_utils.dart';
import 'image_generator.dart';

void main(List<String> arguments) async {
  GeneratedModel model = generateAllAssetsModel();
  writeContentToFile(
      model.resources, model.headers, "R", "lib/generated/r.dart");
}

GeneratedModel generateAllAssetsModel() {
  var model = GeneratedModel([], []);
  model.append(generateColors("res/color/colors.json"));
  model.append(generateAnimations(animationFolderName));
  model.append(generateImages(imageFolderName));
  
  List<String> excludes = List<String>();
  excludes.add(animationFolderName); //exclude the animation folder
  excludes.add(imageFolderName); //exclude the image folder
  model.append(generateAssets(excludes));
  return model;
}

String generateFile(Config config) {
  GeneratedModel model = generateAllAssetsModel();
  var content = generateContent(model.resources, model.headers, "R");
  content = "// ${config.pubspecFilename}\n$content";
  return content;
}