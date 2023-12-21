import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:phone_client/custom_image/custom_image_class.dart' as custom;
import 'package:phone_client/path_searching_algorithm_in_image/support_classes/enums/robot_instructions.dart';
import 'package:phone_client/path_searching_algorithm_in_image/search_maze_algorithms/normalizing_path_to_directions.dart';

import '../../bluetooth/found_devices_widget.dart';

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
            widget.normDirections.robotInstructions.join(' — '),
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
