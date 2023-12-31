import 'coordinate.dart';
import 'enums/directions.dart';

class MappedDirectionsToCoordinates {
  final Directions directions;
  List<Coordinate> coordinates;
  MappedDirectionsToCoordinates(this.directions, this.coordinates);

  @override
  String toString() {
    return directions.toString();
  }
}
