abstract class BluetoothData {
  final dynamic data;
  BluetoothData(this.data);
}

class BluetoothException implements Exception {
  String? msg;
  BluetoothException({this.msg});
}
