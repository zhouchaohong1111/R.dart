
class GeneratedModel {
  List<String> headers;
  List<String> resources;

  GeneratedModel(this.headers, this.resources);

  void append(GeneratedModel a) {
    headers.addAll(a.headers);
    resources.addAll(a.resources);
  }
}