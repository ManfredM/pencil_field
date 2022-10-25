import 'dart:io';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'paint.dart';

/// A stroke is a polyline.
class PencilStroke extends Equatable {
  final List<Point> points;
  final int bezierDistance;
  final PencilPaint pencilPaint;

  const PencilStroke(
      {required this.points,
      required this.bezierDistance,
      required this.pencilPaint});

  /// Returns the number of points that are in this polyline
  int get pointCount => points.length;

  /// Adds a point to the polyline
  PencilStroke addPoint(Point point) {
    return PencilStroke(
        points: [...points, point],
        bezierDistance: bezierDistance,
        pencilPaint: pencilPaint);
  }

  /// Create a scaled copy of this stroke
  PencilStroke scale({required double scale}) {
    final List<Point> scaledPoints = <Point>[];
    for (final point in points) {
      scaledPoints.add(Point(point.x * scale, point.y * scale));
    }
    return PencilStroke(
        points: scaledPoints,
        bezierDistance: bezierDistance,
        pencilPaint: pencilPaint);
  }

  /// Created a versioned json of this stroke. Points are stored in a more
  /// compressed format to save some space.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': 1,
      'points': points.map((p) => '${p.x};${p.y}').toList(),
      'bezierDistance': bezierDistance,
      'paint': pencilPaint.toJson(),
    };
  }

  /// Restore a polyline from a json data map. If the version is not supported
  /// an empty [PencilStroke] with a default [PencilPaint] is returned.
  factory PencilStroke.fromJson(Map<String, dynamic> json) {
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
    if (json['version'] == null) return _emptyStroke();
    if (json['version'] != 1) return _emptyStroke();

    // Decode the stroke
    final List<dynamic> pointsAsString = json['points'] as List<dynamic>;
    return PencilStroke(
        points: pointsAsString.map((pas) {
          final xy = pas.split(';');
          return Point(
            double.parse(xy[0]),
            double.parse(xy[1]),
          );
        }).toList(),
        bezierDistance:
            json['bezierDistance'] != null ? json['bezierDistance'] as int : 1,
        pencilPaint: PencilPaint.fromJson(json['paint']));
  }

  static PencilStroke _emptyStroke() {
    return PencilStroke(
      points: const [],
      bezierDistance: PencilStroke.defaultBezierDistance(),
      pencilPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
    );
  }

  /// Calculate the total extent of this [PencilStroke]
  Size calculateTotalSize() {
    Size size = const Size(0, 0);
    for (final point in points) {
      size = Size(
        max(size.width, point.x.toDouble()),
        max(size.height, point.y.toDouble()),
      );
    }
    return size;
  }

  @override
  List<Object> get props => [points, bezierDistance, pencilPaint];

  /// Creates a path that can be drawn on a canvas
  Path createDrawablePath() {
    //if (bezierDistance == 1) return _drawAsLine();
    return _drawAsBezier();
  }

  /*
  Path _drawAsLine() {
    final path = Path();
    int index = 0;
    path.moveTo(points[index].x.toDouble(), points[index].y.toDouble());
    for (; index < pointCount; index++) {
      path.lineTo(points[index].x.toDouble(), points[index].y.toDouble());
    }
    return path;
  }
  */

  Path _drawAsBezier() {
    // Each path that needs to be reconstructed as bezier path must set
    // the bezierPath property to null.
    Path bezierPath = Path();

    // Correct the bezierDistance to achieve best possible results. These values
    // are empiric corrections.
    int n = bezierDistance;
    if (points.length <= 7 && n > 2) n = 2;
    if (points.length <= 4) n = 1;

    int index = 0;
    bezierPath.moveTo(points[0].x.toDouble(), points[0].y.toDouble());
    if (points.length > 3 * n) {
      for (; index < points.length - 3 * n; index += 3 * n) {
        bezierPath.cubicTo(
          points[index + 1 * n].x.toDouble(),
          points[index + 1 * n].y.toDouble(),
          points[index + 2 * n].x.toDouble(),
          points[index + 2 * n].y.toDouble(),
          points[index + 3 * n].x.toDouble(),
          points[index + 3 * n].y.toDouble(),
        );
      }
    }
    if (points.length - index > 2) {
      bezierPath.quadraticBezierTo(
        points[points.length - 2].x.toDouble(),
        points[points.length - 2].y.toDouble(),
        points[points.length - 1].x.toDouble(),
        points[points.length - 1].y.toDouble(),
      );
    } else {
      for (; index < points.length; index++) {
        bezierPath.lineTo(
          points[index].x.toDouble(),
          points[index].y.toDouble(),
        );
      }
    }
    return bezierPath;
  }

  /// Returns the bezier distance that is used for drawing the line. iOS returns
  /// a pretty dense point cloud while Android is optimized and only returns the
  /// controls points of a bezier curve.
  static int defaultBezierDistance() {
    if (kIsWeb) {
      return 1;
    } else {
      // Platform crashes when running in a browser
      if (Platform.isAndroid) return 3;
      return 1;
    }
  }
}
