import 'package:flutter/material.dart';

/// The different styles that are currently supported
enum PencilDecorationType { blank, lines, chequered, dots }

/// [PencilDecoration] enables configuration the background and layout of a
/// [PencilField] and a [PencilDisplay].
class PencilDecoration {
  final PencilDecorationType type;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color patternColor;
  final double lineWidth;
  final double numberOfLines;

  PencilDecoration({
    this.type = PencilDecorationType.blank,
    this.padding = const EdgeInsets.all(0),
    this.backgroundColor = Colors.transparent,
    this.patternColor = Colors.black54,
    this.lineWidth = 1.0,
    this.numberOfLines = 0,
  }) {
    assert(() {
      if (type != PencilDecorationType.blank && numberOfLines <= 0) {
        debugPrint(
          'numberOfLines must be larger than 0 if a patterned '
          'background shall be used.',
        );
        return false;
      }
      return true;
    }());
  }

  /// Paints the decoration on the given canvas. It can happen that no
  /// decoration is painted if the total width/height minus the given padding
  /// is too small (<= 0).
  void paint(Canvas canvas, Size size) {
    if (type == PencilDecorationType.blank) return;

    final paint = Paint()
      ..color = patternColor
      ..strokeWidth = lineWidth;
    final patternHeight = size.height - padding.top - padding.bottom;
    final patternWidth = size.width - padding.left - padding.right;
    final double ySpacing =
        numberOfLines == 1 ? patternHeight : patternHeight / numberOfLines;
    final double xSpacing = ySpacing;
    final double xStart = padding.top;
    final double yStart = padding.left;

    // there might be padding setting and layout constraints that lead negative
    // heights or width. In this case nothing is painted
    if (patternHeight <= 0.0 || patternWidth <= 0.0) {
      debugPrint(
        'Either pattenHeight ($patternHeight) or '
        'patternWidth ($patternWidth) is less than 0. No pattern will be'
        'painted.',
      );
      return;
    }

    // Draw vertical lines.
    if (type == PencilDecorationType.chequered) {
      for (int iX = 0; iX < patternWidth / xSpacing; iX++) {
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
      for (int iY = 0; iY < numberOfLines + 1; iY++) {
        canvas.drawLine(
          Offset(xStart, yStart + ySpacing * iY),
          Offset(xStart + patternWidth, yStart + ySpacing * iY),
          paint,
        );
      }
    }

    // Draw the dotted pattern
    if (type == PencilDecorationType.dots) {
      for (int iX = 0; iX < patternWidth / xSpacing; iX++) {
        for (int iY = 0; iY < numberOfLines + 1; iY++) {
          canvas.drawCircle(
            Offset(xStart + xSpacing * iX, yStart + ySpacing * iY),
            lineWidth / 2,
            paint,
          );
        }
      }
    }
  }
}
