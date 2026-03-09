import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencil_field/pencil_field.dart';

import 'test_helpers.dart';

void main() {
  group('Radius erase mode', () {
    test('Enter radiusErase mode sets mode correctly', () {
      final controller = PencilFieldController();
      controller.setMode(PencilMode.radiusErase);
      expect(controller.mode, PencilMode.radiusErase);
    });

    test('Custom eraser radius is stored', () {
      final controller = PencilFieldController();
      controller.setMode(PencilMode.radiusErase, eraserRadius: 20.0);
      expect(controller.eraserRadius, 20.0);
    });

    test('Default eraser radius is 10.0', () {
      final controller = PencilFieldController();
      controller.setMode(PencilMode.radiusErase);
      expect(controller.eraserRadius, 10.0);
    });

    test('Sweep across a stroke removes it', () {
      final controller = PencilFieldController();
      final paint = PencilPaint(color: Colors.black, strokeWidth: 2.0);

      // Add strokes manually
      controller.setDrawing(PencilDrawing(strokes: [
        PencilStroke(
          points: const [Point(0, 0), Point(10, 0), Point(20, 0)],
          bezierDistance: 1,
          pencilPaint: paint,
        ),
      ]));
      expect(controller.drawing.strokeCount, 1);

      // Enter radius erase and sweep directly on top
      controller.setMode(PencilMode.radiusErase, eraserRadius: 5.0);
      controller.startPath(startOffset: const Offset(0, 0), pencilPaint: paint);
      controller.addPointToPath(const Offset(20, 0));
      controller.endPath();

      // Stroke should be fully erased
      expect(controller.drawing.strokeCount, 0);
    });

    test('Sweep that misses all strokes changes nothing', () {
      final controller = PencilFieldController();
      final paint = PencilPaint(color: Colors.black, strokeWidth: 2.0);

      controller.setDrawing(PencilDrawing(strokes: [
        PencilStroke(
          points: const [Point(0, 0), Point(10, 0), Point(20, 0)],
          bezierDistance: 1,
          pencilPaint: paint,
        ),
      ]));
      expect(controller.drawing.strokeCount, 1);

      // Erase far away from the stroke
      controller.setMode(PencilMode.radiusErase, eraserRadius: 5.0);
      controller.startPath(
          startOffset: const Offset(0, 100), pencilPaint: paint);
      controller.addPointToPath(const Offset(20, 100));
      controller.endPath();

      expect(controller.drawing.strokeCount, 1);
      expect(controller.drawing.strokeAt(0).pointCount, 3);
    });

    test('Sweep across middle of stroke splits it', () {
      final controller = PencilFieldController();
      final paint = PencilPaint(color: Colors.black, strokeWidth: 2.0);

      controller.setDrawing(PencilDrawing(strokes: [
        PencilStroke(
          points: const [
            Point(0, 0),
            Point(5, 0),
            Point(10, 0),
            Point(15, 0),
            Point(20, 0),
          ],
          bezierDistance: 1,
          pencilPaint: paint,
        ),
      ]));
      expect(controller.drawing.strokeCount, 1);

      // Vertical eraser at x=10 with small radius
      controller.setMode(PencilMode.radiusErase, eraserRadius: 1.0);
      controller.startPath(
          startOffset: const Offset(10, -10), pencilPaint: paint);
      controller.addPointToPath(const Offset(10, 10));
      controller.endPath();

      // Original stroke should be split into 2
      expect(controller.drawing.strokeCount, 2);
    });

    test('Undo after radius erase restores original drawing', () {
      final controller = PencilFieldController();
      final paint = PencilPaint(color: Colors.black, strokeWidth: 2.0);

      controller.setDrawing(PencilDrawing(strokes: [
        PencilStroke(
          points: const [Point(0, 0), Point(10, 0), Point(20, 0)],
          bezierDistance: 1,
          pencilPaint: paint,
        ),
      ]));
      expect(controller.drawing.strokeCount, 1);

      // Erase everything
      controller.setMode(PencilMode.radiusErase, eraserRadius: 5.0);
      controller.startPath(startOffset: const Offset(0, 0), pencilPaint: paint);
      controller.addPointToPath(const Offset(20, 0));
      controller.endPath();
      expect(controller.drawing.strokeCount, 0);

      // Undo should restore
      controller.setMode(PencilMode.write);
      controller.undo();
      expect(controller.drawing.strokeCount, 1);
      expect(controller.drawing.strokeAt(0).pointCount, 3);
    });

    test('Multiple radius erase gestures can be undone independently', () {
      final controller = PencilFieldController();
      final paint = PencilPaint(color: Colors.black, strokeWidth: 2.0);

      controller.setDrawing(PencilDrawing(strokes: [
        PencilStroke(
          points: const [Point(0, 0), Point(10, 0), Point(20, 0)],
          bezierDistance: 1,
          pencilPaint: paint,
        ),
        PencilStroke(
          points: const [Point(0, 50), Point(10, 50), Point(20, 50)],
          bezierDistance: 1,
          pencilPaint: paint,
        ),
      ]));
      expect(controller.drawing.strokeCount, 2);

      // Erase first stroke
      controller.setMode(PencilMode.radiusErase, eraserRadius: 5.0);
      controller.startPath(startOffset: const Offset(0, 0), pencilPaint: paint);
      controller.addPointToPath(const Offset(20, 0));
      controller.endPath();
      expect(controller.drawing.strokeCount, 1);

      // Erase second stroke (need to re-enter mode since setMode short-circuits same mode)
      controller.setMode(PencilMode.write);
      controller.setMode(PencilMode.radiusErase, eraserRadius: 5.0);
      controller.startPath(
          startOffset: const Offset(0, 50), pencilPaint: paint);
      controller.addPointToPath(const Offset(20, 50));
      controller.endPath();
      expect(controller.drawing.strokeCount, 0);

      // Undo second erase
      controller.setMode(PencilMode.write);
      controller.undo();
      expect(controller.drawing.strokeCount, 1);

      // Undo first erase
      controller.undo();
      expect(controller.drawing.strokeCount, 2);
    });

    test('Existing line-intersection erase still works', () {
      final controller = PencilFieldController();
      final paint = PencilPaint(color: Colors.black, strokeWidth: 2.0);

      controller.setDrawing(PencilDrawing(strokes: [
        givenPencilStroke1,
      ]));
      expect(controller.drawing.strokeCount, 1);

      // Use line-intersection erase
      controller.setMode(PencilMode.erase);
      controller.startPath(
          startOffset:
              Offset(givenPoint8.x.toDouble(), givenPoint8.y.toDouble()),
          pencilPaint: paint);
      controller.addPointToPath(
          Offset(givenPoint9.x.toDouble(), givenPoint9.y.toDouble()));
      controller.endPath();
      expect(controller.drawing.strokeCount, 0);

      // Undo should work with old-style undo
      controller.setMode(PencilMode.write);
      controller.undo();
      expect(controller.drawing.strokeCount, 1);
    });

    test('Clear works after radius erase', () {
      final controller = PencilFieldController();
      final paint = PencilPaint(color: Colors.black, strokeWidth: 2.0);

      controller.setDrawing(PencilDrawing(strokes: [
        PencilStroke(
          points: const [Point(0, 0), Point(10, 0)],
          bezierDistance: 1,
          pencilPaint: paint,
        ),
      ]));

      // Erase
      controller.setMode(PencilMode.radiusErase, eraserRadius: 5.0);
      controller.startPath(startOffset: const Offset(0, 0), pencilPaint: paint);
      controller.addPointToPath(const Offset(10, 0));
      controller.endPath();

      // Clear
      controller.clear();
      expect(controller.drawing.strokeCount, 0);
      expect(controller.mode, PencilMode.write);

      // Undo after clear should do nothing
      controller.undo();
      expect(controller.drawing.strokeCount, 0);
    });
  });
}
