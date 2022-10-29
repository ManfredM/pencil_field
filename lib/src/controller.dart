library pencil_field;

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:pencil_field/pencil_field.dart';


/// The pencil can work in two different modes, either draw something or erase
enum PencilMode { write, erase }

class PencilFieldController {
  PencilMode _mode = PencilMode.write;

  // TODO: add change callback

  // all paths that are managed and painted
  PencilDrawing _strokePaths = const PencilDrawing(strokes: <PencilStroke>[]);
  Size? _totalSize;

  // a path that defines the path of the eraser. This path will be used as soon
  // as PartCreationMode.eraser is active.
  List<bool> _writePathsMarkedForErase = <bool>[];
  PencilStroke? _eraserPath;
  bool _atLeastOnePathMarkedForErase = false;
  PencilDrawing _undoPaths = const PencilDrawing(strokes: <PencilStroke>[]);

  PencilDrawing get drawing => _strokePaths;

  void setDrawing(PencilDrawing pencilDrawing) {
    _strokePaths = PencilDrawing(strokes: pencilDrawing.strokes);
    _totalSize = null;
  }

  void setMode(PencilMode mode) {
    // Avoid unnecessary calls
    if (_mode == mode) return;

    _mode = mode;
    switch (_mode) {
      case PencilMode.write:
        _removeWritePathsMarkedForErase();
        break;
      case PencilMode.erase:
        _writePathsMarkedForErase =
            List.generate(_strokePaths.strokeCount, (index) => false);
        _atLeastOnePathMarkedForErase = false;
    }
  }

  /// Return the current mode
  PencilMode get mode => _mode;

  /// Start a new path
  void startPath({
    required Offset startOffset,
    required PencilPaint pencilPaint,
  }) {
    final pencilPath = PencilStroke(
        points: [Point(startOffset.dx, startOffset.dy)],
        bezierDistance: PencilStroke.defaultBezierDistance(),
        pencilPaint: pencilPaint);
    if (_mode == PencilMode.write) {
      _strokePaths = _strokePaths.add(pencilPath);
      _totalSize = null;
    } else {
      _eraserPath = pencilPath;
    }
  }

  /// Add the next point. If working in eraser mode all paths will be
  /// immediately tested for intersection.
  void addPointToPath(Offset offset) {
    switch (_mode) {
      case PencilMode.write:
        _strokePaths.addPointToLastStroke(Point(offset.dx, offset.dy));
        _totalSize = null;
        break;
      case PencilMode.erase:
        _eraserPath = _eraserPath?.addPoint(Point(offset.dx, offset.dy));
        _calculateIntersections();
        break;
    }
  }

  /// End path must be called as soon as the user lifts the pen
  void endPath() {
    if (_mode == PencilMode.erase) {
      // In case of erase mode all paths marked for erase will be removed
      // from the writing paths.
      _removeWritePathsMarkedForErase();
    }
  }

  void _calculateIntersections() {
    // Check the last line that has been added to the eraser path
    if (_eraserPath!.points.length < 2) return;
    //assert(_eraserPath!.points.length >= 2);
    final int eraserIndex = _eraserPath!.points.length - 1;

    // Define the line that will be tested for intersection with a writing
    // path. p1.x must be less or equal than p2.x.
    Point ep1;
    Point ep2;
    if (_eraserPath!.points[eraserIndex - 1].x <=
        _eraserPath!.points[eraserIndex].x) {
      ep1 = _eraserPath!.points[eraserIndex - 1];
      ep2 = _eraserPath!.points[eraserIndex];
    } else {
      ep2 = _eraserPath!.points[eraserIndex - 1];
      ep1 = _eraserPath!.points[eraserIndex];
    }

    // Iterate over all writing paths
    for (int pathIndex = 0; pathIndex < _strokePaths.strokeCount; pathIndex++) {
      // Move to the next path if the one at the index is already marked for
      // erase.
      if (_writePathsMarkedForErase[pathIndex] == true) {
        continue;
      }

      final PencilStroke writePath = _strokePaths.atIndex(index: pathIndex);
      bool intersectionFound = false;
      Point wp1;
      Point wp2;

      // Iterate over all lines in the path and stop immediately if
      // an intersection is found.
      if (writePath.points.length > 1) {
        // we have a line
        for (int pointIndex = 0;
            pointIndex < writePath.points.length - 1 && !intersectionFound;
            pointIndex++) {
          if (writePath.points[pointIndex].x <=
              writePath.points[pointIndex + 1].x) {
            wp1 = writePath.points[pointIndex];
            wp2 = writePath.points[pointIndex + 1];
          } else {
            wp2 = writePath.points[pointIndex];
            wp1 = writePath.points[pointIndex + 1];
          }
          intersectionFound = _segmentIntersection(ep1, ep2, wp1, wp2);
        }
      } else {
        // It's a point. Here wp1 and wp2 are the same. In order to have a
        // line for intersection calculation we create a little virtual
        // cross.
        const epsilon = 2.0;
        wp1 = writePath.points[0];
        wp2 = Point(wp1.x + epsilon, wp1.y + epsilon);
        final wp3 = Point(wp1.x + epsilon, wp1.y - epsilon);
        final wp4 = Point(wp1.x - epsilon, wp1.y + epsilon);
        final wp5 = Point(wp1.x - epsilon, wp1.y - epsilon);
        intersectionFound = _segmentIntersection(ep1, ep2, wp1, wp2);
        intersectionFound |= _segmentIntersection(ep1, ep2, wp1, wp3);
        intersectionFound |= _segmentIntersection(ep1, ep2, wp1, wp4);
        intersectionFound |= _segmentIntersection(ep1, ep2, wp1, wp5);
      }
      if (intersectionFound) {
        _atLeastOnePathMarkedForErase = true;
        _writePathsMarkedForErase[pathIndex] = true;
      }
    }
  }

  // Returns true if two lines defined by their end points intersect with
  // each other.
  bool _segmentIntersection(Point p0, Point p1, Point p2, Point p3) {
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

  void _removeWritePathsMarkedForErase() {
    if (_atLeastOnePathMarkedForErase) {
      for (int reverseIndex = _strokePaths.strokeCount - 1;
          reverseIndex >= 0;
          reverseIndex--) {
        if (_writePathsMarkedForErase[reverseIndex]) {
          PencilStroke deletedPath =
              _strokePaths.removeAtIndex(index: reverseIndex);
          _undoPaths = _undoPaths.add(deletedPath);
        }
      }
      _writePathsMarkedForErase = List.generate(
        _strokePaths.strokeCount,
        (index) => false,
      );
      _atLeastOnePathMarkedForErase = false;

      _totalSize = null;
    }
    _eraserPath = null;
  }

  void undo() {
    if (_undoPaths.strokeCount == 0) return;

    _strokePaths = _strokePaths.add(_undoPaths.lastStroke);
    _totalSize = null;
    _undoPaths.removeLast();
  }

  void clear() {
    _mode = PencilMode.write;
    _strokePaths = const PencilDrawing(strokes: <PencilStroke>[]);
    _totalSize = null;
    _eraserPath = null;
  }

  /// Draw all paths on a canvas
  void draw(Canvas canvas, Size size) {
    Paint paint;
    PencilStroke pencilPath;
    for (int index = 0; index < _strokePaths.strokeCount; index++) {
      pencilPath = _strokePaths.atIndex(index: index);
      paint = pencilPath.pencilPaint.paint;

      // If erase mode is active all paints for paths that are marked for
      // erase will get half of the alpha value.
      if (_mode == PencilMode.erase) {
        if (_writePathsMarkedForErase[index]) {
          paint = PencilPaint(
            color: paint.color.withAlpha(paint.color.alpha ~/ 2),
            strokeWidth: paint.strokeWidth,
          ).paint;
        }
      }
      canvas.drawPath(pencilPath.createDrawablePath(), paint);
    }
    if (_eraserPath != null) {
      if (_eraserPath!.pointCount > 0) {
        canvas.drawPath(
          _eraserPath!.createDrawablePath(),
          _eraserPath!.pencilPaint.paint,
        );
      }
    }
  }

  Size calculateTotalSize() {
    if (_totalSize != null) return _totalSize!;

    Size drawingSize = const Size(0, 0);
    for (final stroke in _strokePaths.strokes) {
      final strokeSize = stroke.calculateTotalSize();
      drawingSize = Size(max(drawingSize.width, strokeSize.width),
          max(drawingSize.height, strokeSize.height));
    }
    return drawingSize;
  }

  /// Get the drawing as an image. The function requires at least an background
  /// color. If the background pattern shall be added the optional parameter
  /// [decoration] can be used. In this case [backgroundColor] will be ignored
  /// and the one in decoration used instead.
  PencilImage drawingAsImage({
    Color? backgroundColor,
    PencilDecoration? decoration,
  }) {
    assert(() {
      if (backgroundColor == null && decoration == null) {
        debugPrint('Either backgroundColor or decoration must be used');
        return false;
      }
      if (backgroundColor != null && decoration != null) {
        debugPrint('Either backgroundColor or decoration can be used');
        return false;
      }
      return true;
    }());

    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Size size = calculateTotalSize();

    // Paint the background first
    final backgroundPaint = Paint();
    backgroundPaint.color =
        decoration == null ? backgroundColor! : decoration.backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      backgroundPaint,
    );

    // Paint the background if available.
    decoration?.paint(canvas, size);

    // paint the drawing and return it
    draw(canvas, size);
    return PencilImage(recorder.endRecording(), size);
  }
}

/// Return the drawing as an image in different formats
class PencilImage {
  final Picture picture;
  final Size size;

  const PencilImage(this.picture, this.size);

  Future<Image> toImage() {
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }

  Future<Uint8List?> toPNG() async {
    final Image image = await toImage();
    final byteImage = await image.toByteData(format: ImageByteFormat.png);
    return byteImage?.buffer.asUint8List();
  }
}
