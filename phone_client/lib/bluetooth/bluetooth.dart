import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

abstract class BluetoothData {
  final dynamic data;
  BluetoothData(this.data);
}

class BluetoothException implements Exception {
  String? msg;
  BluetoothException({this.msg});
}

class BluetoothController extends GetxController {
  Future scanDevices() async {
    // Start scanning
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.advName} found! rssi: ${r.rssi}');
      }
    });
    // Stop scanning
    await FlutterBluePlus.stopScan();
  }

  // scan result stream
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  // connect to device
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
  }
}
