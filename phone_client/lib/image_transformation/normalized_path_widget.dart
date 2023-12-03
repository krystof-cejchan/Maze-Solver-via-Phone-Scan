import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:phone_client/helpers/custom_image_class.dart' as custom;
import 'package:phone_client/image_to_route/classes,enums,exceptions_for_route_algorithm/enums/robot_instructions.dart';
import 'package:phone_client/image_to_route/search_maze_algorithms/normalizing_path_to_directions.dart';

import '../bluetooth/found_devices.dart';

class NormalizedPathWidget extends StatefulWidget {
  const NormalizedPathWidget(this.normDirections, {super.key, this.pathImage});
  final NormalizedPathDirections normDirections;
  final custom.Image? pathImage;
  @override
  State<StatefulWidget> createState() => _NormalizedPathState();
}

/// shows the shortest path with its directions
class _NormalizedPathState extends State<NormalizedPathWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Image.memory(widget.pathImage!.bytes),
          Text(
            widget.normDirections.robotInstructions.toString(),
            style: const TextStyle(
              fontSize: 12,
              backgroundColor: Colors.black87,
              color: Colors.lightBlue,
            ),
          ),
          ElevatedButton(
            onPressed: _goto,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(239, 140, 255, 200),
                foregroundColor: Colors.blueAccent),
            child: const Icon(Icons.bluetooth_audio_sharp),
          ),
        ],
      ),
    );
  }

  void _goto({Queue<RobotInstructions>? robotInstructions}) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BluetoothDevices(
            robotInstructions ?? widget.normDirections.robotInstructions,
          ),
        ),
      );
}
