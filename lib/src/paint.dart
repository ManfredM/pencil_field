import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';


/// [PencilPaint] is derived from [Paint] and adds a few [PencilField]
/// specific capabilities like persistence to that class.
class PencilPaint extends Equatable {
  final Paint paint = Paint();

  PencilPaint({required Color color, required double strokeWidth}) {
    paint.color = color;
    paint.strokeWidth = strokeWidth;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;
    paint.isAntiAlias = true;
  }

  /// Create a copy with modifications.
  PencilPaint copyWith([Color? color, double? strokeWidth]) {
    return PencilPaint(
        color: color ?? paint.color,
        strokeWidth: strokeWidth ?? paint.strokeWidth);
  }

  /// Create a json representation of the object
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'color': paint.color.value.toString(),
      'strokeWidth': paint.strokeWidth,
    };
  }

  /// Restore the object from a json data map.
  factory PencilPaint.fromJson(Map<String, dynamic> json) {
    return PencilPaint(
        color: Color(int.parse(json['color'])),
        strokeWidth: json['strokeWidth']);
  }

  @override
  List<Object> get props => [paint.strokeWidth, paint.color];
}
