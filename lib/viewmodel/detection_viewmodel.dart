import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../data/ml_repository.dart';
import '../data/models/detection_result.dart';

class DetectionViewModel extends ChangeNotifier {
  final MLRepository _repository;

  CameraController? cameraController;
  List<DetectionResult> detections = [];
  bool isInitialized = false;
  bool _isProcessing = false;
  String? error;
  int inferenceTime = 0;

  DetectionViewModel(this._repository);

  Future<void> initCamera(List<CameraDescription> cameras) async {
    if (cameras.isEmpty) {
      error = 'No camera found on this device.';
      notifyListeners();
      return;
    }

    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await cameraController!.initialize();
      isInitialized = true;
      notifyListeners();
      await cameraController!.startImageStream(_onFrame);
    } catch (e) {
      error = 'Camera error: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final start = DateTime.now().millisecondsSinceEpoch;
    try {
      final rotation = cameraController?.description.sensorOrientation ?? 0;
      final results = await _repository.processFrame(image, rotation);
      inferenceTime = DateTime.now().millisecondsSinceEpoch - start;
      detections = results;
    } catch (_) {
      // skip failed frames silently
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    cameraController?.stopImageStream();
    cameraController?.dispose();
    _repository.dispose();
    super.dispose();
  }
}
