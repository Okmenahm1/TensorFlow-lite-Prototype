import 'package:flutter/material.dart';

class DetectionResult {
  final String label;
  final double confidence;
  final Rect boundingBox;

  const DetectionResult({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });
}
