import 'dart:math';

import 'package:flutter/material.dart';

import 'stroke.dart';

/// This value controls the minimum distance required between points that a
/// point is added using [addPointToLastStroke].
const _kMinimumDistance = 0.5;

/// Store a list of paths that belong together
class PencilDrawing {
  PencilDrawing({List<PencilStroke>? strokes}) {
    if (strokes != null) {
      _strokes.addAll(strokes);
    }
  }

  PencilDrawing.from({required PencilDrawing pencilDrawing}) {
    _strokes.addAll(pencilDrawing._strokes);
  }

  final List<PencilStroke> _strokes = [];

  /// Returns the number of strokes in the drawing
  int get strokeCount => _strokes.length;

  /// Adds a new stroke to drawing and returns the number of strokes in
  /// drawing.
  int addStroke({
    required PencilStroke stroke,
  }) {
    _strokes.add(stroke);
    return _strokes.length;
  }

  /// Returns the last stroke in the drawing. Using the property without any
  /// stroke in the drawing will cause an exception.
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

  /// returns a [PencilStroke] at a given index. An exception will be thrown if
  /// [index] is out of range.
  ///
  /// v0.4.0. renamed from atIndex.
  PencilStroke strokeAt(int index) => _strokes[index];

  /// Removes a stroke at given [index]. An exception will be thrown if
  /// [index] is out of range.
  PencilStroke removeStrokeAt(int index) {
    return _strokes.removeAt(index);
  }

  /// Removes the last stroke that has been added to the drawing.
  void removeLastStroke() {
    if (strokeCount == 0) return;
    removeStrokeAt(strokeCount - 1);
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
      scaledPencilStrokes.add(pencilStroke.scale(scale: scale));
    }

    return PencilDrawing(strokes: scaledPencilStrokes);
  }

  /// Adds a point to the last stroke in the drawing. It will only add a point
  /// if the distance between the last point and the new point in more than
  /// [kMinimumDistance] apart from last point in last stroke.
  void addPointToLastStroke(Point point) {
    bool addPoint = true;
    if (_strokes.last.pointCount > 0) {
      final Point previousPoint = _strokes.last.last;
      final num distance = sqrt(
          ((point.x - previousPoint.x) * (point.x - previousPoint.x)) +
              ((point.y - previousPoint.y) * (point.y - previousPoint.y)));
      const epsilon = _kMinimumDistance;
      if (distance < epsilon) addPoint = false;
    }
    if (addPoint) {
      _strokes.last.addPoint(point);
    }
  }

  /// Store the drawing in a versioned jsan map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': 1,
      'strokes': _strokes.map((p) => p.toJson()).toList(),
    };
  }

  /// Restore a drawing from json data. In case versions have changed this
  /// function will take care of the versioning. It will return an empty
  /// drawing in case the version is not supported.
  factory PencilDrawing.fromJson(Map<String, dynamic> json) {
    assert(() {
      if (json['version'] == null) {
        debugPrint(
          'WARNING: No version information provided. The root cause could be'
          'that you are providing a json that was not created by pencil_field '
          'or the json is corrupted.',
        );
        return true;
      }
      if (json['version'] != 1) {
        debugPrint(
          'WARNING: Only version 1 is supported.',
        );
        return true;
      }
      return true;
    }());

    // Make sure there is no crash in production
    if (json['version'] == null) return PencilDrawing(strokes: []);
    if (json['version'] != 1) return PencilDrawing(strokes: []);

    // Decode the strokes
    final pencilStrokes = List<PencilStroke>.from(
        json['strokes'].map((j) => PencilStroke.fromJson(j)));
    return PencilDrawing(strokes: pencilStrokes);
  }
}
