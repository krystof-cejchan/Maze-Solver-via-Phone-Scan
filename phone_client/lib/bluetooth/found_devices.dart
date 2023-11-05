import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDevices extends StatelessWidget {
  late final List<ScanResult> foundDevices;

  BluetoothDevices({super.key}) {
    FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      foundDevices = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(foundDevices
        .map((e) => e.device.remoteId.toString())
        .toList()
        .toString());
  }
}
