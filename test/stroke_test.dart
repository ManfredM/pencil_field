import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencil_field/pencil_field.dart';

import 'test_helpers.dart';

class PencilStrokeTest {
  PencilStrokeTest({
    required this.name,
    this.givenPoints,
    this.givenSegmentPoints,
    this.givenBezierDistance,
    this.givenPaint,
    this.givenScaleFactor,
    this.givenJson,
    this.expectedNumberOfPoints,
    this.expectedSize,
    this.expectedJson,
    this.expectIntersection,
  });

  final String name;
  final List<Point>? givenPoints;
  final List<Point>? givenSegmentPoints;
  final int? givenBezierDistance;
  final PencilPaint? givenPaint;
  final double? givenScaleFactor;
  final String? givenJson;
  final int? expectedNumberOfPoints;
  final Size? expectedSize;
  final String? expectedJson;
  final bool? expectIntersection;
}

void main() {
  group('Test PencilStroke construction\n', () {
    var createTests = <PencilStrokeTest>[
      PencilStrokeTest(
        name: 'Empty\n',
        givenPoints: [],
        givenBezierDistance: 1,
        givenPaint: givenPaint,
        expectedNumberOfPoints: 0,
      ),
      PencilStrokeTest(
        name: 'List of points\n',
        givenPoints: [
          givenPoint1,
          givenPoint2,
          givenPoint3,
          givenPoint4,
        ],
        givenBezierDistance: 1,
        givenPaint: givenPaint,
        expectedNumberOfPoints: givenPencilStroke1PointCount,
      ),
    ];

    for (final createTest in createTests) {
      test(createTest.name, () {
        final result = PencilStroke(
          points: createTest.givenPoints!,
          bezierDistance: createTest.givenBezierDistance!,
          pencilPaint: createTest.givenPaint!,
        );
        expect(result.pointCount, createTest.expectedNumberOfPoints);
      });
    }
  });

  group('Test PencilStroke point handling\n', () {
    final pointTests = <PencilStrokeTest>[
      PencilStrokeTest(
        name: 'Add points to empty stroke\n',
        givenPoints: [
          givenPoint1,
          givenPoint2,
          givenPoint3,
          givenPoint4,
        ],
        expectedNumberOfPoints: givenPencilStroke1PointCount,
        givenBezierDistance: 1,
        givenPaint: givenPaint,
      ),
      PencilStrokeTest(
        name: 'Add points twice to empty stroke\n',
        givenPoints: [
          givenPoint1,
          givenPoint2,
          givenPoint3,
          givenPoint4,
          givenPoint1,
          givenPoint2,
          givenPoint3,
          givenPoint4,
        ],
        expectedNumberOfPoints: givenPencilStroke1PointCount * 2,
        givenBezierDistance: 1,
        givenPaint: givenPaint,
      ),
    ];

    for (final pointTest in pointTests) {
      test(pointTest.name, () {
        var result = PencilStroke(
          points: const [],
          bezierDistance: pointTest.givenBezierDistance!,
          pencilPaint: pointTest.givenPaint!,
        );
        for (final point in pointTest.givenPoints!) {
          result.addPoint(point);
        }
        expect(result.pointCount, pointTest.expectedNumberOfPoints);
      });
    }
  });

  group('Test PencilStroke scaling\n', () {
    final scaleTests = <PencilStrokeTest>[
      PencilStrokeTest(
        name: 'Scale by 0.5\n',
        givenPoints: [
          givenPoint1,
          givenPoint2,
          givenPoint3,
          givenPoint4,
          givenPoint5,
          givenPoint6,
          givenPoint7,
        ],
        givenBezierDistance: 1,
        givenPaint: givenPaint,
        givenScaleFactor: 0.5,
        expectedNumberOfPoints:
            givenPencilStroke1PointCount + givenPencilStroke2PointCount,
        expectedSize: Size(
          givenDrawingSize.width * 0.5,
          givenDrawingSize.height * 0.5,
        ),
      ),
      PencilStrokeTest(
        name: 'Scale by 2\n',
        givenPoints: [
          givenPoint1,
          givenPoint2,
          givenPoint3,
          givenPoint4,
          givenPoint5,
          givenPoint6,
          givenPoint7,
        ],
        givenBezierDistance: 1,
        givenPaint: givenPaint,
        givenScaleFactor: 2.0,
        expectedNumberOfPoints:
            givenPencilStroke1PointCount + givenPencilStroke2PointCount,
        expectedSize: Size(
          givenDrawingSize.width * 2.0,
          givenDrawingSize.height * 2.0,
        ),
      ),
    ];

    for (final scaleTest in scaleTests) {
      test(scaleTest.name, () {
        var unscaledStroke = PencilStroke(
          points: const [],
          bezierDistance: 1,
          pencilPaint: scaleTest.givenPaint!,
        );
        for (final point in scaleTest.givenPoints!) {
          unscaledStroke.addPoint(point);
        }
        PencilStroke result = unscaledStroke.scale(
          scale: scaleTest.givenScaleFactor!,
        );
        expect(result.calculateTotalSize(), scaleTest.expectedSize!);
      });
    }
  });

  group('Intersection calculation', () {
    final intersectionTests = <PencilStrokeTest>[
      PencilStrokeTest(
        name: 'Intersection found',
        givenPoints: [givenPoint4, givenPoint3],
        givenSegmentPoints: [givenPoint8, givenPoint9],
        givenBezierDistance: 1,
        givenPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
        expectIntersection: true,
      ),
      PencilStrokeTest(
        name: 'No intersection found',
        givenPoints: [givenPoint1, givenPoint2],
        givenSegmentPoints: [givenPoint8, givenPoint9],
        givenBezierDistance: 1,
        givenPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
        expectIntersection: false,
      ),
      PencilStrokeTest(
        name: 'Find intersection with point',
        givenPoints: [givenPoint10],
        givenSegmentPoints: [givenPoint3, givenPoint4],
        givenBezierDistance: 1,
        givenPaint: PencilPaint(color: Colors.black, strokeWidth: 2.0),
        expectIntersection: true,
      ),
    ];

    for (final interactionTest in intersectionTests) {
      test(interactionTest.name, () {
        final stroke = PencilStroke(
          points: interactionTest.givenPoints!,
          bezierDistance: interactionTest.givenBezierDistance!,
          pencilPaint: interactionTest.givenPaint!,
        );

        final result = stroke.intersectsWithSegment(
          interactionTest.givenSegmentPoints![0],
          interactionTest.givenSegmentPoints![1],
        );
        expect(result, interactionTest.expectIntersection!);
      });
    }
  });

  group('Test PencilStroke persistence\n', () {
    final persistenceTests = <PencilStrokeTest>[
      PencilStrokeTest(
        name: 'Save and restore with known version\n',
        givenPoints: [
          givenPoint1,
          givenPoint2,
          givenPoint3,
          givenPoint4,
        ],
        givenBezierDistance: 1,
        givenPaint: givenPaint,
        expectedNumberOfPoints: givenPencilStroke1PointCount,
      ),
      PencilStrokeTest(
        name: 'Load a version that is not supported\n',
        givenBezierDistance: 1,
        givenJson:
            '{"version":2,"points":["0;0","0;20","20;20","20;0"],"bezierDistance":1,"paint":{"color":"4278190080","strokeWidth":2.0}}',
        expectedNumberOfPoints: 0,
      ),
      PencilStrokeTest(
        name:
            'Load json with invalid point format (first point only has x coordinate)\n',
        givenBezierDistance: 1,
        givenJson:
            '{"version":1,"points":["0","0;20","20;20","20;0"],"bezierDistance":1,"paint":{"color":"4278190080","strokeWidth":2.0}}',
        expectedNumberOfPoints: 0,
      ),
    ];

    for (final persistenceTest in persistenceTests) {
      test(persistenceTest.name, () {
        if (persistenceTest.givenPoints != null) {
          // Store and load test
          final stroke = PencilStroke(
            points: persistenceTest.givenPoints!,
            bezierDistance: persistenceTest.givenBezierDistance!,
            pencilPaint: persistenceTest.givenPaint!,
          );
          final json = stroke.toJson();

          // Comment out to generate json for testing
          //print(jsonEncode(json));

          final result = PencilStroke.fromJson(json);
          expect(result.pointCount, persistenceTest.expectedNumberOfPoints!);
        }
        if (persistenceTest.givenJson != null) {
          // Restore from invalid json data.
          final result = PencilStroke.fromJson(
            jsonDecode(persistenceTest.givenJson!),
          );
          expect(result.pointCount, persistenceTest.expectedNumberOfPoints!);
        }
      });
    }
  });

  group('Point-to-segment distance', () {
    test('Point on the segment returns distance 0', () {
      // Point (10, 10) is on the segment from (0,0) to (20,20)
      final result = PencilStroke.pointToSegmentDistance(
        const Point(10, 10),
        const Point(0, 0),
        const Point(20, 20),
      );
      expect(result, closeTo(0.0, 0.001));
    });

    test('Point perpendicular to segment midpoint', () {
      // Horizontal segment from (0,0) to (10,0), point at (5,3) => distance 3
      final result = PencilStroke.pointToSegmentDistance(
        const Point(5, 3),
        const Point(0, 0),
        const Point(10, 0),
      );
      expect(result, closeTo(3.0, 0.001));
    });

    test('Point beyond segment endpoint returns distance to nearest endpoint',
        () {
      // Segment from (0,0) to (10,0), point at (15,0) => distance 5 (to end)
      final result = PencilStroke.pointToSegmentDistance(
        const Point(15, 0),
        const Point(0, 0),
        const Point(10, 0),
      );
      expect(result, closeTo(5.0, 0.001));
    });

    test('Degenerate segment (start == end) returns distance to point', () {
      // Segment from (5,5) to (5,5), point at (8,9) => distance 5
      final result = PencilStroke.pointToSegmentDistance(
        const Point(8, 9),
        const Point(5, 5),
        const Point(5, 5),
      );
      expect(result, closeTo(5.0, 0.001));
    });
  });

  group('Stroke splitting by radius', () {
    final paint = PencilPaint(color: Colors.black, strokeWidth: 2.0);

    test('Eraser misses stroke entirely — returns original stroke', () {
      final stroke = PencilStroke(
        points: const [Point(0, 0), Point(10, 0), Point(20, 0)],
        bezierDistance: 1,
        pencilPaint: paint,
      );
      final result = stroke.splitByRadius(
        eraserPoints: const [Point(0, 50), Point(20, 50)],
        radius: 5.0,
      );
      expect(result.length, 1);
      expect(result[0], same(stroke)); // Same object returned
    });

    test('Eraser covers entire stroke — returns empty list', () {
      final stroke = PencilStroke(
        points: const [Point(5, 0), Point(10, 0), Point(15, 0)],
        bezierDistance: 1,
        pencilPaint: paint,
      );
      // Eraser path right on top with large radius
      final result = stroke.splitByRadius(
        eraserPoints: const [Point(0, 0), Point(20, 0)],
        radius: 5.0,
      );
      expect(result.length, 0);
    });

    test('Eraser crosses middle — returns two sub-strokes', () {
      // Vertical stroke with widely-spaced points
      final stroke = PencilStroke(
        points: const [
          Point(0, 0),
          Point(0, 200),
          Point(0, 400),
          Point(0, 600),
          Point(0, 800),
        ],
        bezierDistance: 1,
        pencilPaint: paint,
      );
      // Eraser at (30, 400) — 30 units right of point (0,400)
      // with radius 35: the sweep body intersects the bezier curve
      // near (0,400), producing two surviving sub-strokes
      final result = stroke.splitByRadius(
        eraserPoints: const [Point(30, 400)],
        radius: 35.0,
      );
      expect(result.length, 2);
      // Each sub-stroke has multiple points (densely sampled)
      expect(result[0].pointCount, greaterThanOrEqualTo(2));
      expect(result[1].pointCount, greaterThanOrEqualTo(2));
    });

    test('Eraser covers one end — returns one shorter stroke', () {
      // Vertical stroke with widely-spaced points
      final stroke = PencilStroke(
        points: const [
          Point(0, 0),
          Point(0, 200),
          Point(0, 400),
          Point(0, 600),
        ],
        bezierDistance: 1,
        pencilPaint: paint,
      );
      // Eraser centered at (0,100) with radius 101 — covers the
      // start portion of the rendered curve
      final result = stroke.splitByRadius(
        eraserPoints: const [Point(0, 100)],
        radius: 101.0,
      );
      expect(result.length, 1);
      expect(result[0].pointCount, greaterThanOrEqualTo(2));
    });

    test('Single-point stroke within radius — returns empty', () {
      final stroke = PencilStroke(
        points: const [Point(5, 5)],
        bezierDistance: 1,
        pencilPaint: paint,
      );
      final result = stroke.splitByRadius(
        eraserPoints: const [Point(5, 5)],
        radius: 1.0,
      );
      expect(result.length, 0);
    });

    test('Single-point stroke outside radius — returns original', () {
      final stroke = PencilStroke(
        points: const [Point(5, 5)],
        bezierDistance: 1,
        pencilPaint: paint,
      );
      final result = stroke.splitByRadius(
        eraserPoints: const [Point(50, 50)],
        radius: 1.0,
      );
      expect(result.length, 1);
      expect(result[0], same(stroke));
    });

    test('Split strokes preserve paint and bezier distance', () {
      final customPaint = PencilPaint(color: Colors.red, strokeWidth: 4.0);
      final stroke = PencilStroke(
        points: const [
          Point(0, 0),
          Point(0, 50),
          Point(0, 100),
          Point(0, 150),
          Point(0, 200),
        ],
        bezierDistance: 1,
        pencilPaint: customPaint,
      );
      final result = stroke.splitByRadius(
        eraserPoints: const [Point(5, 100)],
        radius: 10.0,
      );
      expect(result.length, 2);
      for (final splitStroke in result) {
        expect(splitStroke.bezierDistance, 1);
        expect(
          PencilPaint.colorToInt(splitStroke.pencilPaint.paint.color),
          PencilPaint.colorToInt(Colors.red),
        );
        expect(splitStroke.pencilPaint.paint.strokeWidth, 4.0);
      }
    });
  });
}
