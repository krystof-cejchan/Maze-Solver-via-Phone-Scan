import '../helpers/custom_image_class.dart' as custom;

class Path {
  final List<List<int>>? coordinatesOfPath;
  final custom.Image image;
  Path(this.image, {this.coordinatesOfPath});
}
