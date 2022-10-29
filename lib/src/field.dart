library pencil_field;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pencil_field/pencil_field.dart';

typedef OnPencilDrawingChanged = void Function(PencilDrawing pencilDrawing);

class PencilField extends StatefulWidget {
  final PencilFieldController controller;
  final PencilPaint pencilPaint;
  final PencilDecoration? decoration;
  final OnPencilDrawingChanged? onPencilDrawingChanged;
  final bool pencilOnly;

  const PencilField({
    super.key,
    required this.controller,
    required this.pencilPaint,
    this.decoration,
    this.onPencilDrawingChanged,
    this.pencilOnly = false,
  });

  @override
  State<PencilField> createState() => _PencilFieldState();
}

class _PencilFieldState extends State<PencilField> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        color: Colors.transparent,
        child: Listener(
          onPointerDown: (details) {
            if (acceptInput(details.kind)) {
              setState(() {
                widget.controller.startPath(
                  startOffset: details.localPosition,
                  pencilPaint: widget.pencilPaint,
                );
              });
            }
          },
          onPointerMove: (details) {
            if (widget.pencilOnly && details.kind != PointerDeviceKind.stylus) {
              return;
            }
            if (acceptInput(details.kind)) {
              setState(() {
                widget.controller.addPointToPath(details.localPosition);
                widget.onPencilDrawingChanged!(PencilDrawing.from(
                    pencilDrawing: widget.controller.drawing));
              });
            }
          },
          onPointerUp: (details) {
            if (acceptInput(details.kind)) {
              setState(() {
                widget.controller.endPath();
                widget.onPencilDrawingChanged!(PencilDrawing.from(
                    pencilDrawing: widget.controller.drawing));
              });
            }
          },
          child: CustomPaint(
            painter: _PencilFieldPainter(
              widget.controller,
              widget.decoration ?? PencilDecoration(),
            ),
          ),
        ),
      ),
    );
  }

  bool acceptInput(PointerDeviceKind pointerDeviceKind) {
    // There is no callback to accept the input. For web also mounted must be
    // checked. It seems that the widget gets mounted slower than on
    // iOS/Android leading to exceptions.
    if (widget.onPencilDrawingChanged == null || mounted == false) {
      return false;
    }

    // THe widget shall only accept stylus input. This should be set to false
    // if the field shall be used to e.g., collect a signature via touch.
    if (widget.pencilOnly && pointerDeviceKind != PointerDeviceKind.stylus) {
      return false;
    }

    // In all cases the input is accepted.
    return true;
  }
}

class PencilDisplay extends StatelessWidget {
  final PencilDrawing pencilDrawing;
  final PencilDecoration? decoration;
  final VoidCallback? onTap;

  const PencilDisplay({
    super.key,
    required this.pencilDrawing,
    this.decoration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pencilInteractionController = PencilFieldController();
    pencilInteractionController.setDrawing(pencilDrawing);

    return ClipRect(
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _PencilFieldPainter(
            pencilInteractionController,
            decoration ?? PencilDecoration(),
          ),
        ),
      ),
    );
  }
}

class _PencilFieldPainter extends CustomPainter {
  final PencilFieldController pencilController;
  final PencilDecoration decoration;

  const _PencilFieldPainter(this.pencilController, this.decoration);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the background
    final backgroundPaint = Paint();
    backgroundPaint.color = decoration.backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      backgroundPaint,
    );

    decoration.paint(canvas, size);

    // Paint the handwriting
    pencilController.draw(canvas, size);
  }

  @override
  bool shouldRepaint(_PencilFieldPainter oldDelegate) {
    return true;
  }
}
