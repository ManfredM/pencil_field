import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:pencil_field/pencil_field.dart';

/// The pencil can work in two different modes, either draw something or erase
enum PencilMode { write, erase }

class PencilFieldController {
  PencilMode _mode = PencilMode.write;

  // all paths that are managed and painted
  PencilDrawing _drawing = PencilDrawing(strokes: <PencilStroke>[]);

  // a path that defines the path of the eraser. This path will be used as soon
  // as PartCreationMode.eraser is active.
  List<bool> _writePathsMarkedForErase = <bool>[];
  PencilStroke? _eraserStroke;
  bool _atLeastOnePathMarkedForErase = false;
  PencilDrawing _undoStrokes = PencilDrawing(strokes: <PencilStroke>[]);

  PencilDrawing get drawing => _drawing;

  /// Set the initial strokes of the drawing. For example, this can be used for
  /// automatically generated paths. This sets the mode to writing.
  void setDrawing(PencilDrawing pencilDrawing) {
    _drawing = PencilDrawing.from(pencilDrawing: pencilDrawing);
    _mode = PencilMode.write;
    _atLeastOnePathMarkedForErase = false;
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
            List.generate(_drawing.strokeCount, (index) => false);
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
    final pencilStroke = PencilStroke(
        points: [Point(startOffset.dx, startOffset.dy)],
        bezierDistance: PencilStroke.defaultBezierDistance(),
        pencilPaint: pencilPaint);
    if (_mode == PencilMode.write) {
      //_drawing = _drawing.add(pencilStroke);
      _drawing.addStroke(stroke: pencilStroke);
    } else {
      _eraserStroke = pencilStroke;
    }
  }

  /// Add the next point. If working in eraser mode all paths will be
  /// immediately tested for intersection.
  void addPointToPath(Offset offset) {
    switch (_mode) {
      case PencilMode.write:
        _drawing.addPointToLastStroke(Point(offset.dx, offset.dy));
        break;
      case PencilMode.erase:
        _eraserStroke?.addPoint(Point(offset.dx, offset.dy));
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
    if (_eraserStroke!.pointCount < 2) return;
    final int eraserIndex = _eraserStroke!.pointCount - 1;

    // Define the line that will be tested for intersection with a writing
    // path. p1.x must be less or equal than p2.x.
    Point ep1;
    Point ep2;
    if (_eraserStroke!.pointAt(eraserIndex - 1).x <=
        _eraserStroke!.pointAt(eraserIndex).x) {
      ep1 = _eraserStroke!.pointAt(eraserIndex - 1);
      ep2 = _eraserStroke!.pointAt(eraserIndex);
    } else {
      ep2 = _eraserStroke!.pointAt(eraserIndex - 1);
      ep1 = _eraserStroke!.pointAt(eraserIndex);
    }

    // Iterate over all writing paths
    for (int pathIndex = 0; pathIndex < _drawing.strokeCount; pathIndex++) {
      // Move to the next path if the one at the index is already marked for
      // erase.
      if (_writePathsMarkedForErase[pathIndex] == true) {
        continue;
      }

      final PencilStroke writeStroke = _drawing.strokeAt(pathIndex);
      if (writeStroke.intersectsWithSegment(ep1, ep2)) {
        _atLeastOnePathMarkedForErase = true;
        _writePathsMarkedForErase[pathIndex] = true;
      }
    }
  }

  void _removeWritePathsMarkedForErase() {
    if (_atLeastOnePathMarkedForErase) {
      for (int reverseIndex = _drawing.strokeCount - 1;
          reverseIndex >= 0;
          reverseIndex--) {
        if (_writePathsMarkedForErase[reverseIndex]) {
          PencilStroke deletedStroke = _drawing.removeStrokeAt(reverseIndex);
          //_undoStrokes = _undoStrokes.add(deletedStroke);
          _undoStrokes.addStroke(stroke: deletedStroke);
        }
      }
      _writePathsMarkedForErase = List.generate(
        _drawing.strokeCount,
        (index) => false,
      );
      _atLeastOnePathMarkedForErase = false;
    }
    _eraserStroke = null;
  }

  void undo() {
    if (_undoStrokes.strokeCount == 0) return;

    // Move the last deleted stroke back to the list of strokes
    //_drawing = _drawing.add(_undoStrokes.lastStroke);
    _drawing.addStroke(stroke: _undoStrokes.lastStroke);
    _undoStrokes.removeLastStroke();

    // Add an additional entry to the list of markers.
    _writePathsMarkedForErase.add(false);
  }

  void clear() {
    _mode = PencilMode.write;
    _drawing = PencilDrawing(strokes: <PencilStroke>[]);
    _undoStrokes = PencilDrawing(strokes: <PencilStroke>[]);
    _eraserStroke = null;
  }

  /// Draw all paths on a canvas
  void draw(Canvas canvas, Size size) {
    Paint paint;
    PencilStroke pencilPath;
    for (int index = 0; index < _drawing.strokeCount; index++) {
      pencilPath = _drawing.strokeAt(index);
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
    if (_eraserStroke != null) {
      if (_eraserStroke!.pointCount > 0) {
        canvas.drawPath(
          _eraserStroke!.createDrawablePath(),
          _eraserStroke!.pencilPaint.paint,
        );
      }
    }
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
    final Size size = _drawing.calculateTotalSize();

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

/// Return the drawing as an image in different format
class PencilImage {
  final Picture picture;
  final Size size;

  const PencilImage(this.picture, this.size);

  /// Return the drawing as an [Image]
  Future<Image> toImage() {
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }

  /// Return the image as PNG. This is useful to store the image as a file or
  /// send it to a service that decodes the handwriting and returns the text.
  Future<Uint8List?> toPNG() async {
    final Image image = await toImage();
    final byteImage = await image.toByteData(format: ImageByteFormat.png);
    return byteImage?.buffer.asUint8List();
  }
}
