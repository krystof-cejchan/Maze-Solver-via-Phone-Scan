import 'package:phone_client/path_searching_algorithm_in_image/search_maze_algorithms/search_for_shortest_path_in_array.dart';
import 'package:phone_client/path_searching_algorithm_in_image/support_classes/coordinates.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Tests',
    () {
      test(
        'A path should _ be found',
        () {
          final testGrid = List<List<int>>.filled(50, List<int>.filled(50, 0));

          PathInMatrix pim = PathInMatrix(testGrid, Coordinates(0, 40, 44, 10));

          expect(pim.foundPath.isNotEmpty, true);
        },
      );
      test(
        'A path should NOT be found',
        () {
          final testGrid = List<List<int>>.filled(50, List<int>.filled(50, 1));

          PathInMatrix pim = PathInMatrix(testGrid, Coordinates(0, 40, 44, 10));

          expect(pim.foundPath.isEmpty, true);
        },
      );
    },
  );
}
