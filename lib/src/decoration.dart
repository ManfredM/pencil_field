import 'package:flutter/material.dart';

enum PencilDecorationType { blank, ruled, chequered, dots, custom }

/// A custom provider for the paint to be used. The returned paint will be used
/// to draw the next element. In case null is returned the element is not
/// painted.
typedef PencilDecorationPaintProvider = Paint? Function(
// Index of the row/column that will be painted next starting with 0. If
// vertical lines are painted row will be -1, in case of horizontal lines
// column will be -1. In case the frame is painted both values will be -1.
  int row,
  int column,

// The paint that would be used to paint the element
  Paint paint,
);

/// A custom painter in case a special pattern is needed.
typedef PencilDecorationCustomPainter = void Function({
// Canvas and size like for every paint function
  required Canvas canvas,
  required Size size,

// decoration object
  required PencilDecoration decoration,

// The paint based on the decoration
  required Paint paint,

// Pre-calculated coordinates reflecting the potentially defined padding
  required double xStart,
  required double yStart,
  required double width,
  required double height,
});

class PencilDecoration {
  final PencilDecorationType type;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color patternColor;
  final double strokeWidth;
  final bool hasBorder;
  final int? numberOfLines;
  final double? spacing;

  final PencilDecorationPaintProvider? paintProvider;
  final PencilDecorationCustomPainter? customPainter;

  PencilDecoration({
    this.type = PencilDecorationType.blank,
    this.padding = const EdgeInsets.all(0),
    this.backgroundColor = Colors.transparent,
    this.patternColor = Colors.black54,
    this.strokeWidth = 1.0,
    this.hasBorder = false,
    this.numberOfLines,
    this.spacing,
    this.paintProvider,
    this.customPainter,
  }) {
    assert(() {
      if (type == PencilDecorationType.ruled ||
          type == PencilDecorationType.chequered ||
          type == PencilDecorationType.dots) {
        if (numberOfLines == null && spacing == null) {
          debugPrint(
            'Either numberOfLines or spacing is needed.',
          );
          return false;
        }
        if (numberOfLines != null && spacing != null) {
          debugPrint(
            'Either numberOfLines or spacing can be given.',
          );
          return false;
        }
        if (numberOfLines != null) {
          if (numberOfLines! <= 0) {
            debugPrint(
              'Number of lines must be a positive number.',
            );
            return false;
          }
        }
        if (spacing != null) {
          if (spacing! <= 0) {
            debugPrint(
              'Spacing must be larger than 0.',
            );
            return false;
          }
        }
      }
      if (type == PencilDecorationType.custom && customPainter == null) {
        debugPrint(
          'When using a custom decoration a painter callback mut be given.',
        );
        return false;
      }

      if (paintProvider != null && customPainter != null) {
        debugPrint(
          'Either a paintProvider or a customPainter can be provided.',
        );
        return false;
      }

      return true;
    }());
  }

  /// Paint the decoration. This paint is always done before the actual content
  /// is painted.
  void paint(Canvas canvas, Size size) {
    // Width and height of the pattern
    final patternHeight = size.height - padding.top - padding.bottom;
    final patternWidth = size.width - padding.left - padding.right;

    // There might be padding setting and layout constraints that lead negative
    // heights or width. In this case nothing is painted
    if (patternHeight <= 0.0 || patternWidth <= 0.0) {
      debugPrint(
        'Either pattenHeight ($patternHeight) or '
        'patternWidth ($patternWidth) is less than 0. No pattern will be'
        'painted.',
      );
      return;
    }

    // Starting points of the pattern
    final double xStart = padding.left;
    final double yStart = padding.top;

    // If a customer painter is defined it is called and the functions returns.
    if (type == PencilDecorationType.custom) {
      customPainter?.call(
        canvas: canvas,
        size: size,
        decoration: this,
        paint: Paint()
          ..color = patternColor
          ..strokeWidth = strokeWidth,
        xStart: xStart,
        yStart: yStart,
        width: patternWidth,
        height: patternHeight,
      );
      return;
    }

    // Draw the background
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      backgroundPaint,
    );

    // If type is blank only the background is drawn
    if (type == PencilDecorationType.blank) return;

    // ySpacing will be calculated either based on number of lines or the
    // spacing given.
    late double ySpacing;
    if (type == PencilDecorationType.ruled ||
        type == PencilDecorationType.chequered ||
        type == PencilDecorationType.dots) {
      if (numberOfLines != null) {
        ySpacing =
            numberOfLines == 1 ? patternHeight : patternHeight / numberOfLines!;
      }
      if (spacing != null) {
        ySpacing = spacing!;
      }
    }

    // x spacing is the same as y spacing for the moment
    final double xSpacing = ySpacing;

    // Draw vertical lines.
    if (type == PencilDecorationType.chequered) {
      for (int column = 0; column <= patternWidth / xSpacing; column++) {
        Paint? linePaint = Paint()
          ..color = patternColor
          ..strokeWidth = strokeWidth;
        //..blendMode = BlendMode.srcOver;
        if (paintProvider != null) {
          linePaint = paintProvider?.call(column, -1, linePaint);
        }
        if (linePaint == null) continue;

        canvas.drawLine(
          Offset(xStart + xSpacing * column, padding.top),
          Offset(xStart + xSpacing * column, padding.top + patternHeight),
          linePaint,
        );
      }
    }

    // Draw horizontal lines
    if (type == PencilDecorationType.ruled ||
        type == PencilDecorationType.chequered) {
      for (int row = 0; row <= patternHeight / ySpacing; row++) {
        Paint? linePaint = Paint()
          ..color = patternColor
          ..strokeWidth = strokeWidth;
        if (paintProvider != null) {
          linePaint = paintProvider?.call(-1, row, linePaint);
        }
        if (linePaint == null) continue;

        canvas.drawLine(
          Offset(xStart, yStart + ySpacing * row),
          Offset(xStart + patternWidth, yStart + ySpacing * row),
          linePaint,
        );
      }
    }

    // Draw the dotted pattern
    if (type == PencilDecorationType.dots) {
      for (int column = 0; column <= patternWidth / xSpacing; column++) {
        for (int row = 0; row <= patternHeight / ySpacing; row++) {
          Paint? linePaint = Paint()
            ..color = patternColor
            ..strokeWidth = strokeWidth;
          if (paintProvider != null) {
            linePaint = paintProvider?.call(column, row, linePaint);
          }
          if (linePaint == null) continue;

          canvas.drawCircle(
            Offset(xStart + xSpacing * column, yStart + ySpacing * row),
            strokeWidth / 2,
            linePaint,
          );
        }
      }
    }

    // Finally draw the frame
    if (hasBorder) {
      Paint? linePaint = Paint()
        ..color = patternColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
      if (paintProvider != null) {
        linePaint = paintProvider?.call(-1, -1, linePaint);
      }

      if (linePaint != null) {
        canvas.drawRect(
          Rect.fromLTWH(
            xStart + linePaint.strokeWidth / 2,
            yStart + linePaint.strokeWidth / 2,
            patternWidth - linePaint.strokeWidth,
            patternHeight - linePaint.strokeWidth,
          ),
          linePaint,
        );
      }
    }
  }
}
