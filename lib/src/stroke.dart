import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'paint.dart';

/// This value controls the minimum distance required between points that a
/// point is added using [addPointToLastStroke].
const _kMinimumDistance = 0.1;

class PencilStroke {
  PencilStroke({
    required List<Point> points,
    required this.bezierDistance,
    required this.pencilPaint,
  }) : assert(bezierDistance >= 1 && bezierDistance <= 3) {
    _points.addAll(points);
    _requiresNewPathCreation = true;
    //_createPathAsLine();
  }

  final List<Point> _points = [];

  // Points as delivered by the platform
  //final List<Offset> _rawPoints = [];

  final int bezierDistance;
  final PencilPaint pencilPaint;
  bool _requiresNewPathCreation = false;
  final _path = Path();

  //final List<int> _list = [];

  int get pointCount => _points.length;

  Point get last => _points.last;

  @Deprecated('Will be removed in version 1.0.0.')
  List<Point> get points => _points;

  int addPoint(Point point) {
    // Only if the new points has a certain distance from the last point
    // it will be added to avoid unnecessary high point density.
    //_rawPoints.add(Offset(point.x.toDouble(), point.y.toDouble()));
    _addPointWithMinimumDistance(point);
    return _points.length;
  }

  // Adds a point to the list of points if the minimum distance is exceeded.
  // This avoids having too many points that cannot be differentiated by the
  // user.
  bool _addPointWithMinimumDistance(Point point) {
    if (pointCount == 0) {
      _points.add(point);
      _requiresNewPathCreation = true;
      //_path.moveTo(point.x.toDouble(), point.y.toDouble());
      return true;
    }

    final Point previousPoint = _points.last;
    final num distance = sqrt(
        ((point.x - previousPoint.x) * (point.x - previousPoint.x)) +
            ((point.y - previousPoint.y) * (point.y - previousPoint.y)));
    const epsilon = _kMinimumDistance;
    if (distance > epsilon) {
      _points.add(point);
      _requiresNewPathCreation = true;
      //_path.lineTo(point.x.toDouble(), point.y.toDouble());
      return true;
    }
    return false;
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
    if (_requiresNewPathCreation) {
      _createPathAsLine();
    }
    return _path;
  }

  // Returns a path that is created by connecting all points with a line. To
  // smooth the line, a bezier curve is used.
  Path _createPathAsLine() {
    _path.reset();
    _requiresNewPathCreation = false;

    // First special case: No points
    if (_points.isEmpty) return _path;

    // Second special case: Only one point
    if (_points.length == 1) {
      _path.moveTo(_points[0].x.toDouble(), _points[0].y.toDouble());
      _path.addOval(
        Rect.fromCircle(
          center: Offset(_points[0].x.toDouble(), _points[0].y.toDouble()),
          radius: pencilPaint.paint.strokeWidth / 4,
        ),
      );
      return _path;
    }

    // All other cases: At least two points, thus a quadratic bezier curve
    // can be used to connect the points.
    _path.moveTo(_points[0].x.toDouble(), _points[0].y.toDouble());
    for (int i = 0; i < _points.length - 1; i++) {
      final Offset startPoint = Offset(
        _points[i].x.toDouble(),
        _points[i].y.toDouble(),
      );
      final Offset endPoint = Offset(
        _points[i + 1].x.toDouble(),
        _points[i + 1].y.toDouble(),
      );
      final Offset midPoint = Offset(
        (startPoint.dx + endPoint.dx) / 2,
        (startPoint.dy + endPoint.dy) / 2,
      );

      _path.quadraticBezierTo(
        startPoint.dx,
        startPoint.dy,
        midPoint.dx,
        midPoint.dy,
      );
    }

    return _path;
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

  /// Computes the shortest distance from point [p] to the line segment
  /// defined by [segStart] and [segEnd].
  ///
  /// Uses vector projection clamped to [0,1] to correctly handle the
  /// segment endpoints (i.e., if the closest point on the infinite line
  /// falls outside the segment, the distance to the nearest endpoint
  /// is returned instead).
  static double pointToSegmentDistance(Point p, Point segStart, Point segEnd) {
    final double dx = segEnd.x.toDouble() - segStart.x.toDouble();
    final double dy = segEnd.y.toDouble() - segStart.y.toDouble();
    final double segLengthSq = dx * dx + dy * dy;

    // Degenerate segment (start == end): return distance to that point
    if (segLengthSq == 0.0) {
      final double px = p.x.toDouble() - segStart.x.toDouble();
      final double py = p.y.toDouble() - segStart.y.toDouble();
      return sqrt(px * px + py * py);
    }

    // Project point onto the line, clamped to [0,1]
    double t = ((p.x.toDouble() - segStart.x.toDouble()) * dx +
            (p.y.toDouble() - segStart.y.toDouble()) * dy) /
        segLengthSq;
    t = t.clamp(0.0, 1.0);

    // Closest point on the segment
    final double closestX = segStart.x.toDouble() + t * dx;
    final double closestY = segStart.y.toDouble() + t * dy;

    final double distX = p.x.toDouble() - closestX;
    final double distY = p.y.toDouble() - closestY;
    return sqrt(distX * distX + distY * distY);
  }

  /// Splits this stroke by removing all points that fall within [radius]
  /// of any segment along the eraser path defined by [eraserPoints].
  /// Computes the minimum distance between two line segments:
  /// segment A from [a1] to [a2], and segment B from [b1] to [b2].
  ///
  /// This is the minimum of the four point-to-segment distances.
  static double segmentToSegmentDistance(
      Point a1, Point a2, Point b1, Point b2) {
    return [
      pointToSegmentDistance(a1, b1, b2),
      pointToSegmentDistance(a2, b1, b2),
      pointToSegmentDistance(b1, a1, a2),
      pointToSegmentDistance(b2, a1, a2),
    ].reduce(min);
  }

  /// Splits this stroke by erasing the portions that fall within [radius]
  /// of the eraser path defined by [eraserPoints].
  ///
  /// Uses PathMetrics on the actual rendered bezier path for accurate boundary
  /// detection. Walks the rendered curve densely, finds inside/outside
  /// transitions, then binary-searches on the path offset for the precise
  /// crossing point. Maps boundary positions back to control point indices
  /// via precomputed cumulative arc lengths. Surviving segments keep their
  /// original control points for smoothness.
  ///
  /// - If no part of this stroke is within the sweep → returns `[this]`.
  /// - If the entire stroke is within the sweep → returns `[]`.
  /// - Otherwise → one new stroke per contiguous surviving segment.
  List<PencilStroke> splitByRadius({
    required List<Point> eraserPoints,
    required double radius,
  }) {
    if (_points.isEmpty || eraserPoints.isEmpty) return [this];

    // Build the eraser's bezier path — same construction as rendered strokes
    // This ensures the distance check matches the visualized sweep body.
    final List<Offset> eraserSamples = [];
    if (eraserPoints.length == 1) {
      eraserSamples.add(Offset(
        eraserPoints[0].x.toDouble(),
        eraserPoints[0].y.toDouble(),
      ));
    } else {
      // Build the eraser bezier path
      final eraserPath = Path();
      eraserPath.moveTo(
        eraserPoints[0].x.toDouble(),
        eraserPoints[0].y.toDouble(),
      );
      for (int i = 0; i < eraserPoints.length - 1; i++) {
        final cp = Offset(
          eraserPoints[i].x.toDouble(),
          eraserPoints[i].y.toDouble(),
        );
        final np = Offset(
          eraserPoints[i + 1].x.toDouble(),
          eraserPoints[i + 1].y.toDouble(),
        );
        final mid = Offset((cp.dx + np.dx) / 2, (cp.dy + np.dy) / 2);
        eraserPath.quadraticBezierTo(cp.dx, cp.dy, mid.dx, mid.dy);
      }
      // Sample the eraser path densely
      final eraserMetrics = eraserPath.computeMetrics().toList();
      for (final em in eraserMetrics) {
        final len = em.length;
        const step = 3.0;
        for (double d = 0; d <= len; d += step) {
          final t = em.getTangentForOffset(d);
          if (t != null) eraserSamples.add(t.position);
        }
        // Always include the endpoint
        final lastT = em.getTangentForOffset(len);
        if (lastT != null) eraserSamples.add(lastT.position);
      }
    }

    // Special case: single-point stroke
    if (_points.length == 1) {
      final px = _points[0].x.toDouble();
      final py = _points[0].y.toDouble();
      double minDist = double.infinity;
      if (eraserSamples.length == 1) {
        final dx = px - eraserSamples[0].dx;
        final dy = py - eraserSamples[0].dy;
        minDist = sqrt(dx * dx + dy * dy);
      } else {
        for (int j = 0; j < eraserSamples.length - 1; j++) {
          final dist = pointToSegmentDistance(
            _points[0],
            Point(eraserSamples[j].dx.round(), eraserSamples[j].dy.round()),
            Point(eraserSamples[j + 1].dx.round(),
                eraserSamples[j + 1].dy.round()),
          );
          if (dist < minDist) minDist = dist;
        }
      }
      return minDist <= radius ? [] : [this];
    }

    // Helper: check if a point is inside the sweep body
    // Uses densely-sampled eraser bezier path for accurate distance
    bool isInside(double px, double py) {
      if (eraserSamples.length == 1) {
        final dx = px - eraserSamples[0].dx;
        final dy = py - eraserSamples[0].dy;
        return sqrt(dx * dx + dy * dy) <= radius;
      }
      final p = Point(px.round(), py.round());
      for (int j = 0; j < eraserSamples.length - 1; j++) {
        final dist = pointToSegmentDistance(
          p,
          Point(eraserSamples[j].dx.round(), eraserSamples[j].dy.round()),
          Point(
              eraserSamples[j + 1].dx.round(), eraserSamples[j + 1].dy.round()),
        );
        if (dist <= radius) return true;
      }
      return false;
    }

    // Get the actual rendered bezier path and its metrics
    final path = createDrawablePath();
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return [this];
    final metric = metrics.first;
    final totalLength = metric.length;
    if (totalLength == 0) return [this];

    // Precompute cumulative arc lengths at each control point's
    // corresponding position on the rendered path.
    // The path goes: p0 → mid(p0,p1) → mid(p1,p2) → ... → mid(pn-2,pn-1)
    // Each bezier segment i: from prev_end to mid(p[i],p[i+1]), control=p[i]
    // We compute the path offset at each midpoint boundary.
    final segmentEndOffsets = <double>[0.0]; // offset at start (p0)

    // Build individual segment paths to measure their lengths
    double cumulativeLength = 0;
    for (int i = 0; i < _points.length - 1; i++) {
      final segPath = Path();
      final p0 = _points[i];
      final p1 = _points[i + 1];

      if (i == 0) {
        segPath.moveTo(p0.x.toDouble(), p0.y.toDouble());
      } else {
        final prev = _points[i - 1];
        segPath.moveTo(
          (prev.x + p0.x) / 2.0,
          (prev.y + p0.y) / 2.0,
        );
      }

      segPath.quadraticBezierTo(
        p0.x.toDouble(),
        p0.y.toDouble(),
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0,
      );

      final segMetrics = segPath.computeMetrics().toList();
      final segLen = segMetrics.isNotEmpty ? segMetrics.first.length : 0.0;
      cumulativeLength += segLen;
      segmentEndOffsets.add(cumulativeLength);
    }

    // Walk the rendered path, sample every ~2 pixels, detect transitions
    const double sampleStep = 2.0;
    bool? prevInside;
    double? prevOffset;
    // List of (offset, entering) — entering=true means outside→inside
    final transitions = <(double, bool)>[];

    for (double d = 0; d <= totalLength; d += sampleStep) {
      final tangent = metric.getTangentForOffset(d);
      if (tangent == null) continue;
      final pos = tangent.position;
      final inside = isInside(pos.dx, pos.dy);

      if (prevInside != null && inside != prevInside) {
        // Binary search on path offset for precise boundary
        double lo = prevOffset ?? (d - sampleStep);
        double hi = d;
        for (int iter = 0; iter < 20; iter++) {
          final mid = (lo + hi) / 2;
          final midT = metric.getTangentForOffset(mid);
          if (midT == null) break;
          final midInside = isInside(midT.position.dx, midT.position.dy);
          if (midInside == prevInside) {
            lo = mid;
          } else {
            hi = mid;
          }
        }
        final boundaryOffset = (lo + hi) / 2;
        transitions.add((boundaryOffset, !prevInside));
      }

      prevInside = inside;
      prevOffset = d;
    }

    // No transitions and first sample was outside → nothing erased
    if (transitions.isEmpty) {
      final firstT = metric.getTangentForOffset(0);
      if (firstT != null && !isInside(firstT.position.dx, firstT.position.dy)) {
        return [this];
      }
      // First sample was inside → fully erased
      return [];
    }

    // Map a path offset to a control point index (which segment it falls in)
    int offsetToSegmentIndex(double offset) {
      for (int i = 0; i < segmentEndOffsets.length - 1; i++) {
        if (offset <= segmentEndOffsets[i + 1]) return i;
      }
      return _points.length - 2;
    }

    // Get the position on the rendered curve at a given offset
    Point positionAtOffset(double offset) {
      final t = metric.getTangentForOffset(offset.clamp(0, totalLength));
      if (t == null) return _points[0];
      return Point(t.position.dx.round(), t.position.dy.round());
    }

    // Build result strokes from transitions
    // Determine if the path starts inside or outside
    final firstT = metric.getTangentForOffset(0);
    final startsInside =
        firstT != null && isInside(firstT.position.dx, firstT.position.dy);

    final List<PencilStroke> result = [];

    // Process transitions to build surviving segments
    // Each pair of (exit, entry) transitions bounds an outside segment
    // If starts outside: first segment is [0, first_entry]
    // If starts inside: first segment is [first_exit, second_entry]
    int transIdx = 0;

    if (!startsInside) {
      // Path starts outside — collect until first entry transition
      if (transitions.isEmpty || !transitions[0].$2) {
        // No entry transition → entire path survives
        return [this];
      }

      // First transition is an entry (outside→inside)
      final entryOffset = transitions[0].$1;
      final entrySegIdx = offsetToSegmentIndex(entryOffset);
      final boundaryPoint = positionAtOffset(entryOffset);

      // Collect control points from start to entrySegIdx + boundary
      final List<Point> run = [];
      for (int i = 0; i <= entrySegIdx; i++) {
        run.add(_points[i]);
      }
      run.add(boundaryPoint);
      if (run.length >= 2) {
        result.add(PencilStroke(
          points: run,
          bezierDistance: bezierDistance,
          pencilPaint: pencilPaint,
        ));
      }
      transIdx = 1;
    }

    // Process remaining transitions in pairs (exit, entry)
    while (transIdx < transitions.length) {
      // Current should be an exit transition (inside→outside)
      if (transIdx < transitions.length && !transitions[transIdx].$2) {
        final exitOffset = transitions[transIdx].$1;
        final exitSegIdx = offsetToSegmentIndex(exitOffset);
        final exitPoint = positionAtOffset(exitOffset);
        transIdx++;

        // Find the next entry transition (outside→inside)
        double? entryOffset;
        int? entrySegIdx;
        Point? entryPoint;
        if (transIdx < transitions.length && transitions[transIdx].$2) {
          entryOffset = transitions[transIdx].$1;
          entrySegIdx = offsetToSegmentIndex(entryOffset);
          entryPoint = positionAtOffset(entryOffset);
          transIdx++;
        }

        // Build surviving run from exitPoint through original control points
        final List<Point> run = [exitPoint];
        final endIdx = entrySegIdx ?? (_points.length - 1);
        for (int i = exitSegIdx + 1; i <= endIdx; i++) {
          run.add(_points[i]);
        }
        if (entryPoint != null) {
          run.add(entryPoint);
        }
        if (run.length >= 2) {
          result.add(PencilStroke(
            points: run,
            bezierDistance: bezierDistance,
            pencilPaint: pencilPaint,
          ));
        }
      } else {
        transIdx++; // skip unexpected transition
      }
    }

    // If the path ends outside and we haven't captured the tail
    if (prevInside != null && !prevInside) {
      // Check if last transition was an exit (inside→outside)
      if (transitions.isNotEmpty && !transitions.last.$2) {
        // Already handled above
      }
    }

    return result.isEmpty ? [] : result;
  }
}
