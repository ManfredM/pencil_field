import 'package:flutter/material.dart';

enum PencilDecorationType { blank, lines, chequered, dots, custom }

/// A custom painter in case a special pattern is needed.
typedef PencilDecorationCustomPainter = void Function({
// decoration object
  PencilDecoration decoration,

// The paint based on the decoration
  Paint paint,

// Pre-calculated coordinates reflecting the potentially defined padding
  double xStart,
  double yStart,
  double width,
  double height,

// Canvas and size like for every paint function
  Canvas canvas,
  Size size,
});

class PencilDecoration {
  final PencilDecorationType type;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color patternColor;
  final double lineWidth;
  final bool hasFrame;
  final double? numberOfLines;
  final double? spacing;

  final PencilDecorationCustomPainter? customPainter;

  PencilDecoration({
    this.type = PencilDecorationType.blank,
    this.padding = const EdgeInsets.all(0),
    this.backgroundColor = Colors.transparent,
    this.patternColor = Colors.black54,
    this.lineWidth = 1.0,
    this.hasFrame = false,
    this.numberOfLines,
    this.spacing,
    this.customPainter,
  }) {
    assert(() {
      if (type == PencilDecorationType.lines ||
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

      return true;
    }());
  }

  /// Paint the decoration. This paint is always done before the actual content
  /// is painted.
  void paint(Canvas canvas, Size size) {
    if (type == PencilDecorationType.blank) return;

    // All predefined pattern go here
    final paint = Paint()
      ..color = patternColor
      ..strokeWidth = lineWidth;

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
        decoration: this,
        paint: paint,
        xStart: xStart,
        yStart: yStart,
        width: patternWidth,
        height: patternHeight,
        canvas: canvas,
        size: size,
      );
      return;
    }

    // ySpacing will be calculated either based on number of lines or the
    // spacing given.
    late double ySpacing;
    if (type == PencilDecorationType.lines ||
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
      for (int iX = 0; iX <= patternWidth / xSpacing; iX++) {
        canvas.drawLine(
          Offset(xStart + xSpacing * iX, padding.top),
          Offset(xStart + xSpacing * iX, padding.top + patternHeight),
          paint,
        );
      }
    }

    // Draw horizontal lines
    if (type == PencilDecorationType.lines ||
        type == PencilDecorationType.chequered) {
      for (int iY = 0; iY <= patternHeight / ySpacing; iY++) {
        canvas.drawLine(
          Offset(xStart, yStart + ySpacing * iY),
          Offset(xStart + patternWidth, yStart + ySpacing * iY),
          paint,
        );
      }
    }

    // Draw the dotted pattern
    if (type == PencilDecorationType.dots) {
      for (int iX = 0; iX <= patternWidth / xSpacing; iX++) {
        for (int iY = 0; iY <= patternHeight / ySpacing; iY++) {
          canvas.drawCircle(
            Offset(xStart + xSpacing * iX, yStart + ySpacing * iY),
            lineWidth / 2,
            paint,
          );
        }
      }
    }

    // Finally draw the frame
    if (hasFrame) {
      canvas.drawLine(
        Offset(xStart + patternWidth, yStart),
        Offset(xStart + patternWidth, yStart + patternHeight),
        paint,
      );
      canvas.drawLine(
        Offset(xStart , yStart+ patternHeight),
        Offset(xStart + patternWidth, yStart + patternHeight),
        paint,
      );
    }
  }
}
