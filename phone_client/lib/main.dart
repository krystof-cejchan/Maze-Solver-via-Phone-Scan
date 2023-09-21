import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:phone_client/image_scanning.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(
    camera: cameras.first,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.camera});

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Maze Solver — Phone client',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 231, 174, 5)),
          useMaterial3: true,
        ),
        home: CameraScreen(
          camera: camera,
        ));
  }
}
