import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:phone_client/bluetooth/bluetooth.dart';
import 'package:phone_client/image_to_route/classes,enums,exceptions_for_route_algorithm/enums/robot_instructions.dart';

import 'bluetooth_controller.dart';

class BluetoothDevices extends StatefulWidget implements BluetoothData {
  final Queue<RobotInstructions> robotInstructions;
  const BluetoothDevices(this.robotInstructions, {super.key});
  @override
  get data => robotInstructions;

  @override
  State<StatefulWidget> createState() => _BluetoothState();
}

class _BluetoothState extends State<BluetoothDevices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLE SCANNER"),
        centerTitle: true,
      ),
      body: GetBuilder<BluetoothController>(
        init: BluetoothController(),
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 15,
                ),
                StreamBuilder<List<ScanResult>>(
                    stream: controller.scanResults,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final data = snapshot.data![index];
                              return Card(
                                elevation: 2,
                                child: ListTile(
                                  title: Text(data.device.toString()),
                                  subtitle: Text(data.device.id.id),
                                  trailing: Text(data.rssi.toString()),
                                ),
                              );
                            });
                      } else {
                        return const Center(
                          child: Text("No Device Found"),
                        );
                      }
                    }),
                ElevatedButton(
                    onPressed: () => controller.scanDevices(),
                    child: const Text("Scan")),
                const SizedBox(
                  height: 15,
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
