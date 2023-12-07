import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  Stream<List<ScanResult>> get scanResults => flutterBlue.scanResults;

  void scanDevices() async {
    var blePermission = await Permission.bluetoothScan.status;
    if (blePermission.isDenied) {
      if (await Permission.bluetoothScan.request().isGranted) {
        if (await Permission.bluetoothConnect.request().isGranted) {
          flutterBlue
              .startScan(timeout: const Duration(seconds: 10))
              .whenComplete(() => flutterBlue.stopScan());
        }
      }
    } else {
      flutterBlue
          .startScan(timeout: const Duration(seconds: 10))
          .whenComplete(() => flutterBlue.stopScan());
    }
  }

  void connectTo(BluetoothDevice target) =>
      target.connect(timeout: const Duration(seconds: 10));

  Future<void> sendData(dynamic data, BluetoothDevice device) async {
    // it takes a few tries to connect; arduino need to be restarted when wanting to appear as connected
    device.connect(timeout: const Duration(seconds: 10)); //?
    List<BluetoothService> services = await device.discoverServices();

    for (var service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          List<int> bytes = utf8.encode(jsonEncode(data));
          await characteristic.write(bytes);
        }
      }
    }
  }

  Stream<List<BluetoothDevice>> isDeviceConnected(BluetoothDevice target) =>
      flutterBlue.connectedDevices.asStream();
}
