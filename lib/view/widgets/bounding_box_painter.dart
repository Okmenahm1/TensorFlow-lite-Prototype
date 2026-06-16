import 'package:flutter/material.dart';
import '../../data/models/detection_result.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final Size imageSize;

  const BoundingBoxPainter({
    required this.detections,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width == 0 || imageSize.height == 0) return;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final boxPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final bgPaint = Paint()
      ..color = Colors.green.withValues(alpha:0.75)
      ..style = PaintingStyle.fill;

    for (final d in detections) {
      final rect = Rect.fromLTRB(
        d.boundingBox.left * scaleX,
        d.boundingBox.top * scaleY,
        d.boundingBox.right * scaleX,
        d.boundingBox.bottom * scaleY,
      );

      canvas.drawRect(rect, boxPaint);

      final label =
          '${d.label}  ${(d.confidence * 100).toStringAsFixed(0)}%';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);

      final labelRect = Rect.fromLTWH(
        rect.left,
        rect.top - tp.height - 4,
        tp.width + 8,
        tp.height + 4,
      );
      canvas.drawRect(labelRect, bgPaint);
      tp.paint(canvas, Offset(rect.left + 4, rect.top - tp.height - 2));
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter old) =>
      old.detections != detections || old.imageSize != imageSize;
}
