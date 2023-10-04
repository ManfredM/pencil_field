import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencil_field/pencil_field.dart';

import 'test_helpers.dart';

class PencilDrawingTest {
  const PencilDrawingTest({
    required this.name,
    this.givenPoints,
    this.givenPaint,
    this.givenBezierDistance,
    this.givenStrokes,
    this.givenDrawing,
    this.givenScale,
    this.givenJson,
    this.expectedStrokeCount,
    this.expectedSize,
    this.expectedJson,
    this.expectedPointCount,
    this.runner,
  });

  final String name;
  final List<Point>? givenPoints;
  final PencilPaint? givenPaint;
  final int? givenBezierDistance;
  final List<PencilStroke>? givenStrokes;
  final PencilDrawing? givenDrawing;
  final double? givenScale;
  final String? givenJson;
  final int? expectedStrokeCount;
  final Size? expectedSize;
  final String? expectedJson;
  final int? expectedPointCount;
  final Function(PencilDrawingTest drawingTest)? runner;
}

void main() {
  group('Test PencilDrawing construction', () {
    final constructionTests = <PencilDrawingTest>[
      const PencilDrawingTest(
        name: 'Create empty drawing.',
        givenStrokes: [],
        expectedStrokeCount: 0,
      ),
      PencilDrawingTest(
        name: 'Create drawing with initial strokes.',
        givenStrokes: [givenPencilStroke1, givenPencilStroke2],
        expectedStrokeCount: 2,
      ),
      PencilDrawingTest(
        name: 'Create drawing from drawing',
        givenDrawing: PencilDrawing(
          strokes: [givenPencilStroke1, givenPencilStroke2],
        ),
        expectedStrokeCount: 2,
      )
    ];

    for (final constructionTest in constructionTests) {
      test(constructionTest.name, () {
        late PencilDrawing result;
        if (constructionTest.givenStrokes != null) {
          result = PencilDrawing(
            strokes: constructionTest.givenStrokes!,
          );
        }
        if (constructionTest.givenDrawing != null) {
          result = PencilDrawing.from(
            pencilDrawing: constructionTest.givenDrawing!,
          );
        }
        expect(result.strokeCount, constructionTest.expectedStrokeCount);
      });
    }
  });

  group('Test PencilDrawing stroke handling', () {
    final strokeAndPointTests = <PencilDrawingTest>[
      PencilDrawingTest(
        name: 'Add single point to drawing',
        givenPoints: [givenPoint1],
        givenPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
        givenBezierDistance: 1,
        expectedStrokeCount: 1,
        runner: (strokeAndPointTest) {
          final result = PencilDrawing();
          result.addStroke(
            stroke: PencilStroke(
              points: strokeAndPointTest.givenPoints!,
              bezierDistance: strokeAndPointTest.givenBezierDistance!,
              pencilPaint: strokeAndPointTest.givenPaint!,
            ),
          );
          expect(result.strokeCount, strokeAndPointTest.expectedStrokeCount);
          expect(
            result.lastStroke.pointCount,
            strokeAndPointTest.givenPoints!.length,
          );
          expect(
            result.strokeAt(0).pointCount,
            strokeAndPointTest.givenPoints!.length,
          );
        },
      ),
      PencilDrawingTest(
        name: 'Add stroke to drawing',
        givenPoints: [givenPoint1, givenPoint2, givenPoint3, givenPoint4],
        givenPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
        givenBezierDistance: 1,
        expectedStrokeCount: 1,
        runner: (strokeAndPointTest) {
          final result = PencilDrawing();
          result.addStroke(
            stroke: PencilStroke(
              points: strokeAndPointTest.givenPoints!,
              bezierDistance: strokeAndPointTest.givenBezierDistance!,
              pencilPaint: strokeAndPointTest.givenPaint!,
            ),
          );
          expect(result.strokeCount, strokeAndPointTest.expectedStrokeCount);
          expect(
            result.lastStroke.pointCount,
            strokeAndPointTest.givenPoints!.length,
          );
          expect(
            result.strokeAt(0).pointCount,
            strokeAndPointTest.givenPoints!.length,
          );
        },
      ),
      PencilDrawingTest(
        name: 'Remove strokes',
        givenPoints: [givenPoint1, givenPoint2, givenPoint3, givenPoint4],
        givenPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
        givenBezierDistance: 1,
        expectedStrokeCount: 0,
        runner: (strokeAndPointTest) {
          final result = PencilDrawing();
          result.addStroke(
            stroke: PencilStroke(
              points: strokeAndPointTest.givenPoints!,
              bezierDistance: strokeAndPointTest.givenBezierDistance!,
              pencilPaint: strokeAndPointTest.givenPaint!,
            ),
          );

          result.removeLastStroke();
          expect(result.strokeCount, strokeAndPointTest.expectedStrokeCount);
        },
      ),
      PencilDrawingTest(
        name: 'Scaling and size calculation strokes',
        givenPoints: [givenPoint1, givenPoint2, givenPoint3, givenPoint4],
        givenPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
        givenBezierDistance: 1,
        givenScale: 0.5,
        expectedSize: Size(
          givenPencilStroke1Size.width * 0.5,
          givenPencilStroke1Size.height * 0.5,
        ),
        runner: (strokeAndPointTest) {
          final originalDrawing = PencilDrawing();
          originalDrawing.addStroke(
            stroke: PencilStroke(
              points: strokeAndPointTest.givenPoints!,
              bezierDistance: strokeAndPointTest.givenBezierDistance!,
              pencilPaint: strokeAndPointTest.givenPaint!,
            ),
          );

          final resultDrawing =
              originalDrawing.scale(scale: strokeAndPointTest.givenScale!);
          final result = resultDrawing.calculateTotalSize();
          expect(result.height, strokeAndPointTest.expectedSize!.height);
          expect(result.width, strokeAndPointTest.expectedSize!.width);
        },
      ),
    ];

    for (final strokeAndPointTest in strokeAndPointTests) {
      test(strokeAndPointTest.name, () {
        strokeAndPointTest.runner!(strokeAndPointTest);
      });
    }
  });

  group('Add point to drawing', () {
    final pointTests = <PencilDrawingTest>[
      PencilDrawingTest(
        name: 'Add 2 point to path',
        givenPoints: [givenPoint1, givenPoint2],
        givenPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
        givenBezierDistance: 1,
        expectedPointCount: 2,
      ),
      PencilDrawingTest(
        name: 'Add 3 point to path, but 3rd point is too close to 2nd point '
            'and should not be added.',
        givenPoints: [givenPoint1, givenPoint2, givenPoint2],
        givenPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
        givenBezierDistance: 1,
        expectedPointCount: 2,
      ),
    ];

    for (final pointTest in pointTests) {
      test(pointTest.name, () {
        final result = PencilDrawing(
          strokes: [
            PencilStroke(
              points: [],
              bezierDistance: pointTest.givenBezierDistance!,
              pencilPaint: pointTest.givenPaint!,
            ),
          ],
        );
        for (final point in pointTest.givenPoints!) {
          result.addPointToLastStroke(point);
        }
        expect(result.strokeAt(0).pointCount, pointTest.expectedPointCount);
      });
    }
  });

  group('PencilDrawing persistence', () {
    // Helper for json load tests
    void restoreFromJsonRunner(PencilDrawingTest persistenceTest) {
      final result = PencilDrawing.fromJson(
        jsonDecode(persistenceTest.givenJson!),
      );
      expect(result.strokeCount, persistenceTest.expectedStrokeCount!);
    }

    final persistenceTests = <PencilDrawingTest>[
      PencilDrawingTest(
        name: 'Store as json',
        givenStrokes: [givenPencilStroke1, givenPencilStroke2],
        expectedJson:
            '{"version":1,"strokes":[{"version":1,"points":["0;0","0;20","20;20","20;0"],"bezierDistance":1,"paint":{"color":"4278190080","strokeWidth":2.0}},{"version":1,"points":["10;10","30;10","40;0"],"bezierDistance":1,"paint":{"color":"4278190080","strokeWidth":2.0}}]}',
        runner: (persistenceTest) {
          final resultDrawing = PencilDrawing(
            strokes: persistenceTest.givenStrokes,
          );
          final result = resultDrawing.toJson();
          expect(jsonEncode(result), persistenceTest.expectedJson);
        },
      ),
      PencilDrawingTest(
        name: 'Restore from json',
        givenStrokes: [givenPencilStroke1, givenPencilStroke2],
        givenJson:
            '{"version":1,"strokes":[{"version":1,"points":["0;0","0;20","20;20","20;0"],"bezierDistance":1,"paint":{"color":"4278190080","strokeWidth":2.0}},{"version":1,"points":["10;10","30;10","40;0"],"bezierDistance":1,"paint":{"color":"4278190080","strokeWidth":2.0}}]}',
        expectedStrokeCount: 2,
        runner: restoreFromJsonRunner,
      ),
      PencilDrawingTest(
        name: 'Restore from json with wrong version number',
        givenStrokes: [givenPencilStroke1, givenPencilStroke2],
        givenJson:
            '{"version":2,"strokes":[{"version":1,"points":["0;0","0;20","20;20","20;0"],"bezierDistance":1,"paint":{"color":"4278190080","strokeWidth":2.0}},{"version":1,"points":["10;10","30;10","40;0"],"bezierDistance":1,"paint":{"color":"4278190080","strokeWidth":2.0}}]}',
        expectedStrokeCount: 0,
        runner: restoreFromJsonRunner,
      ),
    ];

    for (final persistenceTest in persistenceTests) {
      test(persistenceTest.name, () {
        persistenceTest.runner!(persistenceTest);
      });
    }
  });
}
