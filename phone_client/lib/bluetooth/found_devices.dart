import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:phone_client/bluetooth/bluetooth.dart';
import 'package:phone_client/maze_route/classes,enums,exceptions_for_route_algorithm/enums/robot_instructions.dart';

class BluetoothDevices extends StatefulWidget implements BluetoothData {
  final List<ScanResult> foundDevices;
  final Queue<RobotInstructions> robotInstructions;
  const BluetoothDevices(this.robotInstructions, this.foundDevices,
      {super.key});
  @override
  get data => robotInstructions;

  @override
  State<StatefulWidget> createState() => _BluetoothState();
}

class _BluetoothState extends State<BluetoothDevices> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.foundDevices
        .map((e) => e.device.remoteId.toString())
        .toString());
  }

  @override
  void initState() {
    super.initState();
  }
}
