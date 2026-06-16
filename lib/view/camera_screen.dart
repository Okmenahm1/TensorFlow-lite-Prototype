import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../viewmodel/detection_viewmodel.dart';
import 'widgets/bounding_box_painter.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndInit();
  }

  Future<void> _requestPermissionAndInit() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      context.read<DetectionViewModel>().initCamera(widget.cameras);
    } else {
      setState(() => _permissionGranted = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionGranted) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  color: Colors.greenAccent, size: 72),
              const SizedBox(height: 20),
              const Text(
                'Camera Permission Required',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'EdgeVision needs camera access\nto detect objects on-device.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _requestPermissionAndInit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Grant Permission',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'EdgeVision — Offline AI',
          style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<DetectionViewModel>(
        builder: (context, vm, _) {
          if (vm.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  vm.error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final controller = vm.cameraController;
          if (controller == null || !controller.value.isInitialized) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.greenAccent),
                  SizedBox(height: 16),
                  Text(
                    'Starting camera...',
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            );
          }

          // On Android the preview is rotated 90°, so width/height are swapped
          final previewSize = controller.value.previewSize!;
          final imageSize = Size(previewSize.height, previewSize.width);

          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller),

              // Bounding boxes overlay
              CustomPaint(
                painter: BoundingBoxPainter(
                  detections: vm.detections,
                  imageSize: imageSize,
                ),
              ),

              // ON-DEVICE badge (top-right)
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.greenAccent.withValues(alpha:0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'ON-DEVICE  •  OFFLINE',
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ),

              // Status bar (bottom)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.greenAccent.withValues(alpha:0.3)),
                    ),
                    child: Text(
                      vm.detections.isEmpty
                          ? 'Point camera at any object'
                          : '${vm.detections.length} object(s) detected  •  ${vm.inferenceTime} ms',
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
