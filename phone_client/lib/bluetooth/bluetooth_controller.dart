import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  Future<List<ScanResult>> scanDevices() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    List<ScanResult> res = [];
    FlutterBluePlus.scanResults.listen((results) => res.addAll(results));

    await FlutterBluePlus.stopScan();
    return res;
  }

  Stream<List<ScanResult>> get scanResults => scanDevices().asStream();

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
  }
}
