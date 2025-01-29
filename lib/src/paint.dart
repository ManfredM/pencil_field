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
    // color.value is being deprecated. To keep compatibilty here is a copy
    // of the original value function.

    return <String, dynamic>{
      //'color': colorToInt(paint.color).toString(),
      'color': colorToInt(paint.color).toString(),
      'strokeWidth': paint.strokeWidth,
    };
  }

  factory PencilPaint.fromJson(Map<String, dynamic> json) {
    return PencilPaint(
        color: Color(int.parse(json['color'])),
        strokeWidth: json['strokeWidth']);
  }

  // Convert a color value into a 32 bit integer
  static int colorToInt(Color color) {
    return (_floatToInt8(color.a) << 24) |
        (_floatToInt8(color.r) << 16) |
        (_floatToInt8(color.g) << 8) |
        _floatToInt8(color.b);
  }

  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }
}
