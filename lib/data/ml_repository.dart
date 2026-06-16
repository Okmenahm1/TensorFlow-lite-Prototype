import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'models/detection_result.dart';

class MLRepository {
  final ObjectDetector _detector;

  MLRepository()
      : _detector = ObjectDetector(
          options: ObjectDetectorOptions(
            mode: DetectionMode.stream,
            classifyObjects: true,
            multipleObjects: true,
          ),
        );

  Future<List<DetectionResult>> processFrame(
      CameraImage image, int sensorOrientation) async {
    final inputImage = _buildInputImage(image, sensorOrientation);
    if (inputImage == null) return [];

    final objects = await _detector.processImage(inputImage);
    return objects.map((obj) {
      final label = obj.labels.isNotEmpty ? obj.labels.first.text : 'Object';
      final confidence =
          obj.labels.isNotEmpty ? obj.labels.first.confidence : 0.0;
      return DetectionResult(
        label: label,
        confidence: confidence,
        boundingBox: obj.boundingBox,
      );
    }).toList();
  }

  InputImage? _buildInputImage(CameraImage image, int sensorOrientation) {
    final rotation = _rotationFromDegrees(sensorOrientation);
    final size = Size(image.width.toDouble(), image.height.toDouble());

    if (Platform.isAndroid) {
      final bytes = _yuv420ToNv21(image);
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: size,
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );
    }

    if (Platform.isIOS && image.planes.length == 1) {
      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: size,
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    }

    return null;
  }

  // Converts Android YUV_420_888 (3 planes) to NV21 (single byte buffer)
  Uint8List _yuv420ToNv21(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final nv21 = Uint8List(image.width * image.height * 3 ~/ 2);

    // Copy Y plane row by row (may have padding between rows)
    int yIdx = 0;
    for (int row = 0; row < image.height; row++) {
      final src = row * yPlane.bytesPerRow;
      for (int col = 0; col < image.width; col++) {
        nv21[yIdx++] = yPlane.bytes[src + col];
      }
    }

    // Interleave V then U for NV21 format
    int uvIdx = image.width * image.height;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;
    final uPixelStride = uPlane.bytesPerPixel ?? 1;
    for (int row = 0; row < image.height ~/ 2; row++) {
      for (int col = 0; col < image.width ~/ 2; col++) {
        final vOff = row * vPlane.bytesPerRow + col * vPixelStride;
        final uOff = row * uPlane.bytesPerRow + col * uPixelStride;
        nv21[uvIdx++] = vPlane.bytes[vOff];
        nv21[uvIdx++] = uPlane.bytes[uOff];
      }
    }

    return nv21;
  }

  InputImageRotation _rotationFromDegrees(int degrees) {
    switch (degrees) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  void dispose() => _detector.close();
}
