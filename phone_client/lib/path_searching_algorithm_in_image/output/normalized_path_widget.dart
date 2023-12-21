import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:phone_client/custom_image/custom_image_class.dart' as custom;
import 'package:phone_client/helpers/key_generators/keys/key_gen.dart';
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
  List<RobotInstructions> _robotInstructions = List.empty();

  @override
  void initState() {
    setState(() =>
        _robotInstructions = widget.normDirections.robotInstructions.toList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Image.memory(widget.pathImage!.bytes),
          /*Text(
            widget.normDirections.robotInstructions.join(' — '),
            style: const TextStyle(
              fontSize: 12,
              backgroundColor: Colors.black87,
              color: Colors.lightBlue,
            ),
          ),*/
          ReorderableListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: _robotInstructions.length,
            onReorder: (int oldIndex, int newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = _robotInstructions.removeAt(oldIndex);
              setState(() => _robotInstructions.insert(newIndex, item));
            },
            itemBuilder: (BuildContext context, int index) {
              //TODO stream us reused; perhaps try setState()
              return ListTile(
                tileColor: const Color.fromARGB(238, 53, 255, 157),
                key: KeyGen.generate,
                title: Text(_robotInstructions[index].toString()),
                leading: OutlinedButton(
                  clipBehavior: Clip.hardEdge,
                  key: KeyGen.generate,
                  onPressed: () {
                    //TODO does not respond
                    print('object');
                    setState(() => _robotInstructions.removeAt(index));
                  },
                  child: const Icon(Icons.delete_forever),
                ),
                trailing: IconButton(
                  onPressed: () => _addRobotInstructionsAsRow(index),
                  icon: const Icon(Icons.add_circle_outlined),
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                ),
              );
            },
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

  void _addRobotInstructionsAsRow(final int selectedIndex) {
    SimpleDialog(
      title: const Text('Select a RobotInstruction'),
      children: <Widget>[
        for (RobotInstructions robotInstruction in RobotInstructions.values)
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _robotInstructions.insert(selectedIndex + 1, robotInstruction);
              });
            },
            child: Text(robotInstruction.name),
          )
      ],
    );
  }

  void _goto({Queue<RobotInstructions>? robotInstructions}) => Navigator.push(
        //TODO transform the edited list to a queue
        context,
        MaterialPageRoute(
          builder: (context) => BluetoothDevices(
            Queue<RobotInstructions>.from(
              _robotInstructions,
            ),
          ),
        ),
      );
}
