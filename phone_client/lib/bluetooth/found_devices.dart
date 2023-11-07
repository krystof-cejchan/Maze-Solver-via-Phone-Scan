import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:phone_client/bluetooth/bluetooth.dart';
import 'package:phone_client/maze_route/classes,enums,exceptions_for_route_algorithm/enums/robot_instructions.dart';

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
      body: GetBuilder<BluetoothController>(
          init: BluetoothController(),
          builder: (controller) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20 * 3),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.scanDevices();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(350, 55),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      child: const Text(
                        'Scan',
                        style: TextStyle(fontSize: 18),
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
                                onTap: () {},
                                title: Text(device.advName),
                                subtitle: Text(device.remoteId.str),
                                trailing: TextButton(
                                  onPressed: () {
                                    controller.connectToDevice(device);
                                  },
                                  child: Text(
                                    FlutterBluePlus.connectedDevices
                                            .contains(device)
                                        ? 'Connected'
                                        : 'Connect',
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text('No devices found'),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
