import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:phone_client/bluetooth/bluetooth.dart';
import 'package:phone_client/path_searching_algorithm_in_image/support_classes/enums/robot_instructions.dart';

import 'bluetooth_controller.dart';

class BluetoothDevices extends StatefulWidget implements BluetoothData {
  final Queue<RobotInstructions> robotInstructions;
  const BluetoothDevices(this.robotInstructions, {super.key});
  @override
  String get data =>
      robotInstructions.map((e) => e.toString()).toList().toString();

  @override
  State<StatefulWidget> createState() => _BluetoothState();
}

class _BluetoothState extends State<BluetoothDevices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BluetoothController>(
        init: BluetoothController(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20 * 3),
                Center(
                  child: ElevatedButton(
                    onPressed: () => controller.scanDevices(),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(197, 33, 149, 243),
                      minimumSize: const Size(350, 55),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    child: const Text(
                      'SCAN',
                      style: TextStyle(fontSize: 18, letterSpacing: 1.35),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final device = snapshot.data![index].device;
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              tileColor: const Color.fromARGB(80, 53, 161, 250),
                              onTap: () {},
                              title: Text(device.name),
                              subtitle: Text(device.id.id),
                              isThreeLine: false,
                              trailing: TextButton(
                                onPressed: () =>
                                    controller.sendData(widget.data, device),
                                child: StreamBuilder<List<BluetoothDevice>>(
                                  builder: (context, snapshot) => Text(
                                    (snapshot.hasData &&
                                            snapshot.data!.contains(device))
                                        ? 'Connected'
                                        : 'Connect',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  stream: controller.isDeviceConnected(device),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'No devices found',
                          style: TextStyle(
                            color: Colors.deepOrange,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
