import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pencil_field/src/paint.dart';

import 'stroke.dart';

/// Store a list of paths that belong together
class PencilDrawing extends Equatable {
  final List<PencilStroke> _strokes;

  const PencilDrawing({required List<PencilStroke> strokes})
      : _strokes = strokes;

  PencilDrawing.from({required PencilDrawing pencilDrawing})
      : _strokes = pencilDrawing.strokes;

  int get strokeCount => _strokes.length;

  // This property will cause an exception if not strokes are the list
  PencilStroke get lastStroke {
    assert(() {
      if (_strokes.isEmpty) {
        debugPrint('PencilDrawing: Trying to access the last stroke of an '
            'empty list.');
        return false;
      }
      return true;
    }());
    return _strokes.last;
  }

  List<PencilStroke> get strokes => _strokes;

  PencilStroke atIndex({required int index}) => _strokes[index];

  PencilStroke removeAtIndex({required int index}) {
    return _strokes.removeAt(index);
  }

  PencilDrawing add(PencilStroke stroke) {
    return PencilDrawing(strokes: [..._strokes, stroke]);
  }

  void addPointToLastStroke(Point point) {
    bool addPoint = true;
    if (_strokes.last.points.isNotEmpty) {
      final Point previousPoint = _strokes.last.points.last;
      final num distance = sqrt(
          ((point.x - previousPoint.x) * (point.x - previousPoint.x)) +
              ((point.y - previousPoint.y) * (point.y - previousPoint.y)));
      const epsilon = 0.5;
      if (distance < epsilon) addPoint = false;
    }
    if (addPoint) {
      _strokes.last = _strokes.last.addPoint(point);
    }
  }

  void removeLast() {
    _strokes.removeAt(strokeCount - 1);
  }

  Size calculateTotalSize() {
    Size drawingSize = const Size(0, 0);
    for (final stroke in _strokes) {
      final strokeSize = stroke.calculateTotalSize();
      drawingSize = Size(max(drawingSize.width, strokeSize.width),
          max(drawingSize.height, strokeSize.height));
    }
    return drawingSize;
  }

  /// Returns a copy of this drawing scaled by a factor of [scale]
  PencilDrawing scale({required double scale}) {
    final List<PencilStroke> scaledPencilStrokes = <PencilStroke>[];

    // Outer loop: iterate over all strokes in the drawing
    for (final pencilStroke in _strokes) {
      final List<Point> scaledPoints = <Point>[];

      // inner loop: scale all points on a stroke
      for (final point in pencilStroke.points) {
        scaledPoints.add(Point(point.x * scale, point.y * scale));
      }

      // scale the strokeWidth and keep all other paint parameters
      final scaledPencilPaint = PencilPaint(
          color: pencilStroke.pencilPaint.paint.color,
          strokeWidth: pencilStroke.pencilPaint.paint.strokeWidth * scale);

      // create scales stroke and add it to the list of stokes in a drawing
      final scaledPencilStroke = PencilStroke(
          points: scaledPoints,
          bezierDistance: pencilStroke.bezierDistance,
          pencilPaint: scaledPencilPaint);
      scaledPencilStrokes.add(scaledPencilStroke);
    }

    return PencilDrawing(strokes: scaledPencilStrokes);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': 1,
      'strokes': _strokes.map((p) => p.toJson()).toList(),
    };
  }

  factory PencilDrawing.fromJson(Map<String, dynamic> json) {
    assert(() {
      if (json['version'] == null) {
        debugPrint(
          'No version information provided. The root cause could be'
          'that you are providing a json that was not created by pencil_field '
          'or the json is corrupted.',
        );
        return false;
      }
      if (json['version'] != 1) {
        debugPrint(
          'The version of your json is not supported.',
        );
        return false;
      }
      return true;
    }());

    // Make sure there is no crash in production
    if (json['version'] == null) return const PencilDrawing(strokes: []);
    if (json['version'] != 1) return const PencilDrawing(strokes: []);

    // Decode the strokes
    final pencilStrokes = List<PencilStroke>.from(
        json['strokes'].map((j) => PencilStroke.fromJson(j)));
    return PencilDrawing(strokes: pencilStrokes);
  }

  @override
  List<Object> get props => [_strokes];
}
