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
}
