import 'package:flutter/material.dart';

class PencilPaint {
  final Paint paint = Paint();

  PencilPaint({required Color color, required double strokeWidth}) {
    paint.color = color;
    paint.strokeWidth = strokeWidth;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;
    paint.isAntiAlias = true;
  }

  PencilPaint copyWith({Color? color, double? strokeWidth}) {
    return PencilPaint(
        color: color ?? paint.color,
        strokeWidth: strokeWidth ?? paint.strokeWidth);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'color': paint.color.value.toString(),
      'strokeWidth': paint.strokeWidth,
    };
  }

  factory PencilPaint.fromJson(Map<String, dynamic> json) {
    return PencilPaint(
        color: Color(int.parse(json['color'])),
        strokeWidth: json['strokeWidth']);
  }
}
