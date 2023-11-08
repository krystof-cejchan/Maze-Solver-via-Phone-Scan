import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  Future scanDevices() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (kDebugMode) {
          print('${r.device.advName} found! rssi: ${r.rssi}');
        }
      }
    });

    await FlutterBluePlus.stopScan();
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
  }
}
