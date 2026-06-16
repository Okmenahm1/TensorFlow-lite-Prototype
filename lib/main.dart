import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/ml_repository.dart';
import 'view/camera_screen.dart';
import 'viewmodel/detection_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetectionViewModel(MLRepository()),
      child: MaterialApp(
        title: 'EdgeVision',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.greenAccent),
        ),
        home: CameraScreen(cameras: cameras),
      ),
    );
  }
}
