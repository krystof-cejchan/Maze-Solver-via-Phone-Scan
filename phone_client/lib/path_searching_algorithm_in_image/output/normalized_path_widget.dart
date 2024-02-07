import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phone_client/custom_image/custom_image_class.dart' as custom;
import 'package:phone_client/path_searching_algorithm_in_image/support_classes/enums/robot_instructions.dart';
import 'package:phone_client/path_searching_algorithm_in_image/search_maze_algorithms/normalizing_path_to_directions.dart';

import '../../bluetooth/found_devices_widget.dart';

class NormalizedPathWidget extends StatefulWidget {
  NormalizedPathWidget(this.normDirections, {super.key, this.pathImage});
  final NormalizedPathDirections normDirections;
  late final List<RobotInstructions> items =
      normDirections.robotInstructions.toList();

  final custom.Image? pathImage;
  @override
  State<StatefulWidget> createState() => _NormalizedPathState();
}

/// shows the shortest path with its directions
class _NormalizedPathState extends State<NormalizedPathWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.memory(
            widget.pathImage!.bytes,
            height: MediaQuery.of(context).size.height / 2,
          ),
          Expanded(child: _generateRobotInstructions()),
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

  ReorderableListView _generateRobotInstructions() {
    final List<Card> cards = <Card>[
      for (int index = 0; index < widget.items.length; index += 1)
        Card(
          key: Key('$index'),
          color: index.isEven ? Colors.green : Colors.lightGreen,
          child: SizedBox.fromSize(
            size: const Size(50, 104),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /*ListTile(
                  leading: Text(
                    "${index + 1}.",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  title: Text(
                    widget.items[index].toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 25),
                  ),
                  subtitle: Icon(widget.items[index] == RobotInstructions.left
                      ? Icons.roundabout_left_rounded
                      : widget.items[index] == RobotInstructions.right
                          ? Icons.roundabout_right_rounded
                          : Icons.add_road_rounded),
                  isThreeLine: true,
                  dense: true,
                  style: ListTileStyle.drawer,
                ),*/
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${index + 1}.",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    Text(
                      widget.items[index].toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 25),
                    ),
                    Icon(widget.items[index] == RobotInstructions.left
                        ? Icons.roundabout_left_rounded
                        : widget.items[index] == RobotInstructions.right
                            ? Icons.roundabout_right_rounded
                            : Icons.add_road_rounded),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () =>
                            setState(() => widget.items.removeAt(index)),
                        icon: const Icon(Icons.delete_forever)),
                    const SizedBox(width: 8),
                    IconButton(
                        onPressed: () async => _addRobotInstructionToList(
                            await _askAboutRobotInstruction(), index + 1),
                        icon: const Icon(Icons.add_circle)),
                  ],
                ),
              ],
            ),
          ),
        ),
    ];

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(1, 6, animValue)!;
          final double scale = lerpDouble(1, 1.02, animValue)!;
          return Transform.scale(
            scale: scale,
            child: Card(
              elevation: elevation,
              color: cards[index].color,
              child: cards[index].child,
            ),
          );
        },
        child: child,
      );
    }

    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      proxyDecorator: proxyDecorator,
      onReorder: (int oldIndex, int newIndex) {
        setState(
          () {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final RobotInstructions item = widget.items.removeAt(oldIndex);
            widget.items.insert(newIndex, item);
          },
        );
      },
      children: cards,
    );
  }

  Future<RobotInstructions?> _askAboutRobotInstruction() async {
    return await showDialog<RobotInstructions>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shadowColor: Colors.grey,
            title: const Text('Select new instruction'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, RobotInstructions.left);
                },
                child: OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, RobotInstructions.left),
                  child: (const Text(
                    'LEFT',
                    style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  )),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, RobotInstructions.right);
                },
                child: OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, RobotInstructions.right),
                  child: (const Text(
                    'RIGHT',
                    style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  )),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, RobotInstructions.pass);
                },
                child: OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, RobotInstructions.pass),
                  child: (const Text(
                    'PASS',
                    style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  )),
                ),
              ),
            ],
          );
        });
  }

  void _addRobotInstructionToList(
      RobotInstructions? ri, int indexBelowElement) {
    if (ri == null) return;
    setState(() => widget.items.insert(indexBelowElement, ri));
  }

  void _goto({Queue<RobotInstructions>? robotInstructions}) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BluetoothDevices(
            robotInstructions ?? Queue.from(widget.items),
          ),
        ),
      );
}
