/// input: Queue of MappedDirectionsToCoordinates (Directions direction, List of Coordinates going in that direction)
/// output: Queue of MappedDirectionsToCoordinates ( -|| -)
/// 
/// function:
/// if(input's length is less then 1) then return the input
/// 
/// else
/// for each direction
/// curr = direction
/// next = next direction
/// 
/// for each coordinates
/// check whether there are white pixels going in the next direction**
/// 
/// if yes then add pass to output
/// if no then continue;
/// 
/// after completing the direction, add the robot instruction to the output using the method
/// 
/// 
/// 
/// ** →
/// if next direction is left
///   then x--
/// if next direction is right
///   then x++
/// if next direction is up
///   then y--
/// if next direction is down
///   then y++
/// 
/// 
/// 
/// 
/// 
/// 
/// 
/// 
/// 

/* var currMap = mapDirToCoo.removeFirst();
    Queue<MappedDirectionsToCoordinates> patchedMap = Queue()..add(currMap);

    while (mapDirToCoo.isNotEmpty) {
      var next = mapDirToCoo.removeFirst();

      for (var coo in currMap.coordinates) {
        int x = coo.xCoordinate, y = coo.yCoordinate, counter = 0;
        const int thresholdPixels = 100;
        while (_isValidRoute(x, y) && thresholdPixels < counter) {
          switch (next.directions) {
            case Directions.left:
              x--;
              break;
            case Directions.right:
              x++;
              break;
            case Directions.up:
              y--;
              break;
            case Directions.down:
              y++;
              break;
          }
          counter++;
        }

        if (counter >= thresholdPixels) {
          patchedMap.add(currMap);
        } else {
          continue;
        }
      }
      currMap = next;
    }
    return patchedMap;*/














  /*  MappedDirectionsToCoordinates map = mapDirToCoo.removeFirst(), nextMap;
    while (mapDirToCoo.isNotEmpty) {
      nextMap = mapDirToCoo.removeFirst();
      int S = 0;
      patchedMap.add(map);
      for (int i = 0; i < map.coordinates.length; i += 5) {
        var currCoo = map.coordinates[i];
        int counter = 0, x = currCoo.xCoordinate, y = currCoo.yCoordinate;
        while (_isValidRoute(x, y)) {
          switch (nextMap.directions) {
            case Directions.down:
              y++;
              break;
            case Directions.up:
              y--;
              break;
            case Directions.right:
              x++;
              break;
            case Directions.left:
              x--;
              break;
          }
          counter++;
        }

        if (counter <= 100) {
          continue;
        }

        patchedMap.add(
          MappedDirectionsToCoordinates(
            map.directions,
            List<Coordinate>.from(
              map.coordinates.sublist(S, S = i),
            ),
          ),
        );
      }
      map = nextMap;
    }
    patchedMap.forEach((element) {
      print(element.toString());
    });
    return patchedMap;*/