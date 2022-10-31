import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencil_field/pencil_field.dart';

import 'pencil_field_test_data.dart';

class _BackgroundPatternTest {
  final String name;
  final PencilDecoration decoration;
  final String createdImagePath;
  final String expectedImagePath;

  _BackgroundPatternTest({
    required this.name,
    required this.decoration,
    required this.createdImagePath,
    required this.expectedImagePath,
  });
}

class _AcceptPencilOnlyTest {
  final bool pencilOnly;
  final int expectedStrokes;

  _AcceptPencilOnlyTest(
      {required this.pencilOnly, required this.expectedStrokes});
}

PencilImage? createdHelloImageG;

void main() {
  // Test data. It's a very simple drawing that is used for testing. This test
  // data should be expanded with some more complex examples. However, they
  // must be loaded from a file due to the amount of data.
  //
  // (0,0)             (20, 0)               [40,0]
  //   |                  |                   /
  //   |    {10,5}-------------------{30,5}  /
  //   |    [10,10]------------------[30, 10]
  //   |                  |
  //   |                  |
  // (0, 20)-----------(20,20)
  //
  // (givenPencilStroke1), [givenPencilStroke2] are pencil strokes
  // {givenEraserStroke1} is an eraser stroke (will delete (givenPencilStroke1)
  //    when used)
  final givenPaint = PencilPaint(color: Colors.black, strokeWidth: 2);
  final givenPencilStroke1 = PencilStroke(points: const [
    Point(0, 0),
    Point(0, 20),
    Point(20, 20),
    Point(20, 0),
  ], bezierDistance: 1, pencilPaint: givenPaint);
  //const givenPencilStroke1Size = Size(0, 20);
  const givenPencilStroke1Count = 4;
  final givenEraserStroke1 = PencilStroke(points: const [
    Point(10, 5),
    Point(30, 5),
  ], bezierDistance: 1, pencilPaint: givenPaint);
  final givenPencilStroke2 = PencilStroke(points: const [
    Point(10, 10),
    Point(30, 10),
    Point(40, 0),
  ], bezierDistance: 1, pencilPaint: givenPaint);
  //const givenPencilStroke2Size = Size(40, 10);
  const givenDrawingSize = Size(40, 20);

  group('Testing persistence', () {
    test('Tests json encoding and decoding of PencilPaint', () {
      PencilPaint givenPencilPaint =
          PencilPaint(color: Colors.black, strokeWidth: 1);

      final encodedPencilPaint = givenPencilPaint.toJson();
      final decodedPencilPaint = PencilPaint.fromJson(encodedPencilPaint);

      expect(givenPencilPaint, decodedPencilPaint);
    });

    test('Test json encoding and decoding of PencilStroke', () {
      final encodedStrokeAsJson = givenPencilStroke1.toJson();
      final decodedStroke = PencilStroke.fromJson(encodedStrokeAsJson);

      expect(givenPencilStroke1, decodedStroke);
      expect(decodedStroke.pointCount, givenPencilStroke1Count);
    });

    test('Test json encoding and decoding of PencilDrawing', () {
      final givenPencilStrokes =
          PencilDrawing(strokes: [givenPencilStroke1, givenPencilStroke2]);

      final encodedPencilPathModels = givenPencilStrokes.toJson();
      final decodedPencilPathModels =
          PencilDrawing.fromJson(encodedPencilPathModels);

      expect(givenPencilStrokes, decodedPencilPathModels);
    });
  });

  group('Test the stroke and controller', () {
    test('Test if PencilStroke can scale a single stroke', () {
      const scale = 0.5;
      final expectedStrokes = PencilStroke(points: [
        Point(givenPencilStroke1.points[0].x * scale,
            givenPencilStroke1.points[0].y * scale),
        Point(givenPencilStroke1.points[1].x * scale,
            givenPencilStroke1.points[1].y * scale),
        Point(givenPencilStroke1.points[2].x * scale,
            givenPencilStroke1.points[2].y * scale),
        Point(givenPencilStroke1.points[3].x * scale,
            givenPencilStroke1.points[3].y * scale),
      ], bezierDistance: 1, pencilPaint: givenPaint);

      /*final controller =
          PencilStrokeController(pencilStrokes: givenPencilStroke1);*/
      final scaledModel = givenPencilStroke1.scale(scale: 0.5);

      expect(scaledModel, expectedStrokes);
    });

    test('Test if PencilDrawing can scale a set of strokes', () {
      final givenDrawing =
          PencilDrawing(strokes: [givenPencilStroke1, givenPencilStroke2]);
      const expectedSize = Size(20, 10);
      final scaledDrawing = givenDrawing.scale(scale: 0.5);

      expect(scaledDrawing.calculateTotalSize(), expectedSize);
    });

    test('Test all interactions that PencilInteractionsController implements. ',
        () {
      final controller = PencilFieldController();
      final writePaint = PencilPaint(color: Colors.black, strokeWidth: 2.0);
      //final eraserPaint = PencilPaint(color: Colors.white60, strokeWidth: 2.0);

      // Add a point and erase it
      controller.startPath(
          startOffset: const Offset(1, 1), pencilPaint: writePaint);
      controller.endPath();
      controller.setMode(PencilMode.erase);
      controller.startPath(
          startOffset: const Offset(0, 0), pencilPaint: writePaint);
      controller.addPointToPath(const Offset(2, 2));
      controller.endPath();
      controller.setMode(PencilMode.write);
      expect(controller.drawing.strokeCount, 0);

      // Add first of two lines
      final givenPencilOffsets1 = givenPencilStroke1.points
          .map((point) => Offset(point.x.toDouble(), point.y.toDouble()))
          .toList();
      controller.startPath(
          startOffset: givenPencilOffsets1[0], pencilPaint: writePaint);
      for (int i = 1; i < givenPencilOffsets1.length; i++) {
        controller.addPointToPath(givenPencilOffsets1[i]);
      }
      controller.endPath();

      // Add second of two lines
      final givenPencilOffsets2 = givenPencilStroke2.points
          .map((point) => Offset(point.x.toDouble(), point.y.toDouble()))
          .toList();
      controller.startPath(
          startOffset: givenPencilOffsets2[0], pencilPaint: writePaint);
      for (int i = 1; i < givenPencilOffsets2.length; i++) {
        controller.addPointToPath(givenPencilOffsets2[i]);
      }
      controller.endPath();

      // Now there should be two lines in the drawing
      expect(controller.drawing.strokeCount, 2);

      // Test size calculation
      final Size size = controller.drawing.calculateTotalSize();
      expect(size, givenDrawingSize);

      // Test the draw function
      // This test does "only" increase the level of code coverage. There is
      // no expected result at the moment
      final Canvas canvas = Canvas(PictureRecorder());
      controller.draw(canvas, size);

      // Erase the first line
      controller.setMode(PencilMode.erase);
      final givenEraserOffsets1 = givenEraserStroke1.points
          .map((point) => Offset(point.x.toDouble(), point.y.toDouble()))
          .toList();
      controller.startPath(
          startOffset: givenEraserOffsets1[0], pencilPaint: writePaint);
      controller.addPointToPath(givenEraserOffsets1[1]);
      controller.endPath();
      expect(controller.drawing.strokeCount, 1);

      // Undo
      controller.undo();
      expect(controller.drawing.strokeCount, 2);

      // Clear all
      controller.clear();
      expect(controller.drawing.strokeCount, 0);
    });
  });

  group('Test if the background pattern are painted as expected', () {
    Widget createWidgetForTesting({required Widget child}) {
      return MaterialApp(
        home: child,
      );
    }

    testWidgets('Draw all pattern and compare result with saved image',
        (tester) async {
      final widgetTests = [
        _BackgroundPatternTest(
          name: 'lines',
          decoration: PencilDecoration(
            backgroundColor: Colors.white,
            type: PencilDecorationType.lines,
            lineWidth: 2,
            numberOfLines: 5,
          ),
          createdImagePath: 'test/image_output/created_lines_image.png',
          expectedImagePath: 'test/expected_lines_image.png',
        ),
        _BackgroundPatternTest(
          name: 'chequered',
          decoration: PencilDecoration(
            backgroundColor: Colors.white,
            type: PencilDecorationType.chequered,
            lineWidth: 2,
            numberOfLines: 5,
          ),
          createdImagePath: 'test/image_output/expected_chequered_image.png',
          expectedImagePath: 'test/expected_chequered_image.png',
        ),
        _BackgroundPatternTest(
          name: 'dots',
          decoration: PencilDecoration(
            backgroundColor: Colors.white,
            type: PencilDecorationType.dots,
            lineWidth: 2,
            numberOfLines: 5,
          ),
          createdImagePath: 'test/image_output/expected_dots_image.png',
          expectedImagePath: 'test/expected_dots_image.png',
        )
      ];

      final controller = PencilFieldController();

      for (final widgetTest in widgetTests) {
        debugPrint('running test for ${widgetTest.name}');
        await tester.pumpWidget(
          createWidgetForTesting(
            child: PencilField(
              controller: controller,
              pencilPaint: PencilPaint(
                color: Colors.green,
                strokeWidth: 2.0,
              ),
              decoration: widgetTest.decoration,
              onPencilDrawingChanged: (_) {},
              pencilOnly: false,
            ),
          ),
        );

        // Draw a diagonal line to create an image with defined size
        final drawGesture = await tester.startGesture(const Offset(0, 0));
        await drawGesture.moveTo(const Offset(200, 200));
        await drawGesture.up();
        await tester.pumpAndSettle();

        // Get the image with background
        final createdPatternImage =
            controller.drawingAsImage(decoration: widgetTest.decoration);

        // Write the created image (for visual inspection)
        await tester.runAsync<void>(
          () async {
            await _writeImage(
              widgetTest.createdImagePath,
              createdPatternImage,
            );
          },
        );

        await tester.runAsync<void>(
          () async {
            final same = await _compareImages(
                widgetTest.expectedImagePath, createdPatternImage);
            if (same == false) {
              debugPrint(
                'The reason for this failure might be a minimal change '
                'in the drawing routines. Please inspect the expected image '
                'and the image that was created. If they look identical '
                're-generate a new expected image.',
              );
            }
            expect(same, true);
          },
        );
      }
    });
  });

  group('Test the actual widgets with a simple text (hallo)', () {
    Widget createWidgetForTesting({required Widget child}) {
      return MaterialApp(
        home: child,
      );
    }

    testWidgets(
        'Test drawing & erasing on widget with pencilOnly '
        'switched on and off.', (WidgetTester tester) async {
      final widgetTests = [
        _AcceptPencilOnlyTest(pencilOnly: false, expectedStrokes: 1),
        _AcceptPencilOnlyTest(pencilOnly: true, expectedStrokes: 0)
      ];

      final controller = PencilFieldController();

      // Create the widget by telling the tester to build it.
      for (final widgetTest in widgetTests) {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: PencilField(
              controller: controller,
              pencilPaint: PencilPaint(
                color: Colors.green,
                strokeWidth: 2.0,
              ),
              onPencilDrawingChanged: (_) {},
              pencilOnly: widgetTest.pencilOnly,
            ),
          ),
        );

        // Should create one line going from (10, 10) to (20, 20)
        final drawGesture = await tester.startGesture(const Offset(10, 10));
        await drawGesture.moveTo(const Offset(20, 20));
        await drawGesture.up();
        await tester.pumpAndSettle();
        expect(controller.drawing.strokeCount, widgetTest.expectedStrokes);
        if (widgetTest.expectedStrokes > 0) {
          expect(controller.drawing.lastStroke.pencilPaint.paint.color.value,
              Colors.green.value);
        }

        // Should delete the one line
        controller.setMode(PencilMode.erase);
        final eraseGesture = await tester.startGesture(const Offset(15, 15));
        await eraseGesture.moveTo(const Offset(0, 20));
        await eraseGesture.up();
        await tester.pumpAndSettle();
        expect(controller.drawing.strokeCount, 0);
      }
    });
  });

  group('Test the actual widgets with a text and compare with reference', () {
    Widget createWidgetForTesting({required Widget child}) {
      return MaterialApp(
        home: child,
      );
    }

    testWidgets(
        'Write the word "Hallo" and compare the outcome with a '
        'reference picture that is stored on disk.',
        (WidgetTester tester) async {
      final controller = PencilFieldController();

      // Create the widget by telling the tester to build it.
      await tester.pumpWidget(
        createWidgetForTesting(
          child: PencilField(
            controller: controller,
            pencilPaint: PencilPaint(
              color: Colors.green,
              strokeWidth: 2.0,
            ),
            onPencilDrawingChanged: (_) {},
            pencilOnly: false,
          ),
        ),
      );

      final strokes = generateHelloStrokes();
      for (int i = 0; i < strokes.length; i++) {
        final stroke = strokes[i];
        final drawGesture = await tester.startGesture(
          Offset(
            stroke.points[0].x.toDouble(),
            stroke.points[0].y.toDouble(),
          ),
        );
        for (int j = 1; j < stroke.points.length; j++) {
          await drawGesture.moveTo(
            Offset(
              stroke.points[j].x.toDouble(),
              stroke.points[j].y.toDouble(),
            ),
          );
        }
        await drawGesture.up();
        await tester.pumpAndSettle();
      }
      final createdHelloImage =
          controller.drawingAsImage(backgroundColor: Colors.white);

      // This construct does not make too much sense if no new test image is
      // needed. However, the tests never complete if this is excluded from
      // execution???
      await tester.runAsync<void>(
        () async {
          await _writeImage(
              "test/image_output/created_hello_image.png", createdHelloImage);
        },
      );

      await tester.runAsync<void>(
        () async {
          final same = await _compareImages(
              'test/expected_hello_image.png', createdHelloImage);
          if (same == false) {
            debugPrint(
              'The reason for this failure might be a minimal change '
              'in the drawing routines. Please inspect the expected image '
              'and the image that was created. If they look identical '
              're-generate a new expected image.',
            );
          }
          expect(same, true);
        },
      );
    });
  });
}

Future<void> _writeImage(String fileName, PencilImage image) async {
  final helloImagePNG = await image.toPNG();
  File file = File(fileName);
  file.writeAsBytesSync(helloImagePNG!.toList(), flush: true);
}

Future<bool> _compareImages(
    String expectedImagePath, PencilImage createdImage) async {
  File file = File(expectedImagePath);
  final expectedImageAsPNG = file.readAsBytesSync();
  final createdImageAsPNG = await createdImage.toPNG();
  return listEquals(createdImageAsPNG, expectedImageAsPNG);
}
