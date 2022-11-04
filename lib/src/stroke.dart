import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'paint.dart';

class PencilStroke {
  PencilStroke({
    required List<Point> points,
    required this.bezierDistance,
    required this.pencilPaint,
  }) : assert(bezierDistance >= 1 && bezierDistance <= 3) {
    _points.addAll(points);
  }

  final List<Point> _points = [];
  final int bezierDistance;
  final PencilPaint pencilPaint;

  //final List<int> _list = [];

  int get pointCount => _points.length;

  Point get last => _points.last;

  @Deprecated('Will be removed in version 1.0.0.')
  List<Point> get points => _points;

  /*PencilStroke addPoint(Point point) {
    return PencilStroke(
      points: [...points, point],
      bezierDistance: bezierDistance,
      pencilPaint: pencilPaint,
    );
  }*/
  int addPoint(Point point) {
    //_list.add(10);
    _points.add(point);
    return _points.length;
  }

  Point pointAt(int index) => _points[index];

  /// Create a scaled copy of this stroke
  PencilStroke scale({required double scale}) {
    final scaledPoints = <Point>[];
    for (final point in _points) {
      scaledPoints.add(Point(point.x * scale, point.y * scale));
    }

    final scaledPaint = pencilPaint.copyWith(
      strokeWidth: pencilPaint.paint.strokeWidth * scale,
    );
    return PencilStroke(
      points: scaledPoints,
      bezierDistance: bezierDistance,
      pencilPaint: scaledPaint,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': 1,
      'points': _points.map((p) => '${p.x};${p.y}').toList(),
      'bezierDistance': bezierDistance,
      'paint': pencilPaint.toJson(),
    };
  }

  factory PencilStroke.fromJson(Map<String, dynamic> json) {
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

        // Do not fail, but show the warning
        return true;
      }
      return true;
    }());

    // Make sure there is no crash in production
    if (json['version'] == null) return _emptyStroke();
    if (json['version'] != 1) return _emptyStroke();

    // Decode the points
    final List<dynamic> pointsAsString = json['points'] as List<dynamic>;
    bool pointsSuccessfullyDecoded = true;
    final points = pointsAsString.map((pas) {
      final List<String> xy = pas.split(';');
      double? x;
      double? y;
      try {
        x = double.tryParse(xy[0]);
        y = double.tryParse(xy[1]);
      } catch (e) {
        pointsSuccessfullyDecoded = false;
      }
      if (pointsSuccessfullyDecoded) return Point(x!, y!);
      return const Point(0, 0);
    }).toList();
    assert(() {
      if (pointsSuccessfullyDecoded == false) {
        debugPrint('WARNING: One or more points are not formatted correctly.');
      }
      return true;
    }());
    if (pointsSuccessfullyDecoded == false) return _emptyStroke();

    return PencilStroke(
      points: points,
      bezierDistance:
          json['bezierDistance'] != null ? json['bezierDistance'] as int : 1,
      pencilPaint: PencilPaint.fromJson(json['paint']),
    );
  }

  static PencilStroke _emptyStroke() {
    return PencilStroke(
      points: const [],
      bezierDistance: PencilStroke.defaultBezierDistance(),
      pencilPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
    );
  }

  Size calculateTotalSize() {
    Size size = const Size(0, 0);
    for (final point in _points) {
      size = Size(
        max(size.width, point.x.toDouble()),
        max(size.height, point.y.toDouble()),
      );
    }
    return size;
  }

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
    if (_points.length <= 7 && n > 2) n = 2;
    if (_points.length <= 4) n = 1;

    int index = 0;
    bezierPath.moveTo(_points[0].x.toDouble(), _points[0].y.toDouble());
    if (_points.length > 3 * n) {
      for (; index < _points.length - 3 * n; index += 3 * n) {
        bezierPath.cubicTo(
          _points[index + 1 * n].x.toDouble(),
          _points[index + 1 * n].y.toDouble(),
          _points[index + 2 * n].x.toDouble(),
          _points[index + 2 * n].y.toDouble(),
          _points[index + 3 * n].x.toDouble(),
          _points[index + 3 * n].y.toDouble(),
        );
      }
    }
    if (_points.length - index > 2) {
      bezierPath.quadraticBezierTo(
        _points[_points.length - 2].x.toDouble(),
        _points[_points.length - 2].y.toDouble(),
        _points[_points.length - 1].x.toDouble(),
        _points[_points.length - 1].y.toDouble(),
      );
    } else {
      for (; index < _points.length; index++) {
        bezierPath.lineTo(
          _points[index].x.toDouble(),
          _points[index].y.toDouble(),
        );
      }
    }
    return bezierPath;
  }

  /// Calculate if this stroke intersects with a segment defined by start [ip1]
  /// and end [ip2] point.
  bool intersectsWithSegment(Point ip1, Point ip2) {
    bool intersectionFound = false;
    Point p1;
    Point p2;

    // Iterate over all lines in the path and stop immediately if
    // an intersection is found.
    if (pointCount > 1) {
      // we have a line
      for (int pointIndex = 0;
          pointIndex < pointCount - 1 && !intersectionFound;
          pointIndex++) {
        if (pointAt(pointIndex).x <= pointAt(pointIndex + 1).x) {
          p1 = pointAt(pointIndex);
          p2 = pointAt(pointIndex + 1);
        } else {
          p2 = pointAt(pointIndex);
          p1 = pointAt(pointIndex + 1);
        }
        intersectionFound = PencilStroke.segmentIntersection(ip1, ip2, p1, p2);
      }
    } else {
      // It's a point. Here wp1 and wp2 are the same. In order to have a
      // line for intersection calculation we create a little virtual
      // cross.
      const epsilon = 2.0;
      p1 = pointAt(0);
      p2 = Point(p1.x + epsilon, p1.y + epsilon);
      final wp3 = Point(p1.x + epsilon, p1.y - epsilon);
      final wp4 = Point(p1.x - epsilon, p1.y + epsilon);
      final wp5 = Point(p1.x - epsilon, p1.y - epsilon);
      intersectionFound = PencilStroke.segmentIntersection(ip1, ip2, p1, p2);
      intersectionFound |= PencilStroke.segmentIntersection(ip1, ip2, p1, wp3);
      intersectionFound |= PencilStroke.segmentIntersection(ip1, ip2, p1, wp4);
      intersectionFound |= PencilStroke.segmentIntersection(ip1, ip2, p1, wp5);
    }

    return intersectionFound;
  }

  // Returns true if two lines defined by their end points intersect with
  // each other.
  static bool segmentIntersection(Point p0, Point p1, Point p2, Point p3) {
    final num a1 = p1.y - p0.y;
    final num b1 = p0.x - p1.x;
    final num c1 = a1 * p0.x + b1 * p0.y;
    final num a2 = p3.y - p2.y;
    final num b2 = p2.x - p3.x;
    final num c2 = a2 * p2.x + b2 * p2.y;
    final num denominator = a1 * b2 - a2 * b1;

    if (denominator == 0) {
      return false;
    }

    final num intersectX = (b2 * c1 - b1 * c2) / denominator;
    final num intersectY = (a1 * c2 - a2 * c1) / denominator;
    final num rx0 = (intersectX - p0.x) / (p1.x - p0.x);
    final num ry0 = (intersectY - p0.y) / (p1.y - p0.y);
    final num rx1 = (intersectX - p2.x) / (p3.x - p2.x);
    final num ry1 = (intersectY - p2.y) / (p3.y - p2.y);

    if (((rx0 >= 0 && rx0 <= 1) || (ry0 >= 0 && ry0 <= 1)) &&
        ((rx1 >= 0 && rx1 <= 1) || (ry1 >= 0 && ry1 <= 1))) {
      return true;
    } else {
      return false;
    }
  }

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
