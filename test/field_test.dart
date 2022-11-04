import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencil_field/pencil_field.dart';

import 'test_helpers.dart';

class AcceptPencilTest {
  AcceptPencilTest({
    required this.givenPencilOnly,
    required this.expectedStrokes,
  });

  final bool givenPencilOnly;
  final int expectedStrokes;
}

PencilImage? createdHelloImageG;

void main() {
  group('Test PencilField', () {
    Widget createWidgetForTesting({required Widget child}) {
      return MaterialApp(
        home: child,
      );
    }

    testWidgets(
        'Test drawing & erasing on widget with pencilOnly '
        'switched on and off.', (
      WidgetTester tester,
    ) async {
      final acceptPencilTests = <AcceptPencilTest>[
        AcceptPencilTest(givenPencilOnly: false, expectedStrokes: 1),
        AcceptPencilTest(givenPencilOnly: true, expectedStrokes: 0)
      ];

      // Create the widget by telling the tester to build it.
      for (final widgetTest in acceptPencilTests) {
        final controller = PencilFieldController();
        await tester.pumpWidget(
          createWidgetForTesting(
            child: PencilField(
              controller: controller,
              pencilPaint: PencilPaint(
                color: Colors.green,
                strokeWidth: 2.0,
              ),
              onPencilDrawingChanged: (_) {},
              pencilOnly: widgetTest.givenPencilOnly,
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
          expect(
            controller.drawing.lastStroke.pencilPaint.paint.color.value,
            Colors.green.value,
          );
        }

        // Should delete the one line
        controller.setMode(PencilMode.erase);
        final eraseGesture = await tester.startGesture(const Offset(15, 15));
        await eraseGesture.moveTo(const Offset(0, 20));
        await eraseGesture.up();
        await tester.pumpAndSettle();
        expect(controller.drawing.strokeCount, 0);

        // Should undo the delete
        controller.setMode(PencilMode.write);
        controller.undo();
        expect(controller.drawing.strokeCount, widgetTest.expectedStrokes);

        // Finally clear the drawing
        controller.clear();
        expect(controller.drawing.strokeCount, 0);
      }
    });
  });

  group('Hallo', () {
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
            stroke.pointAt(0).x.toDouble(),
            stroke.pointAt(0).y.toDouble(),
          ),
        );
        for (int j = 1; j < stroke.pointCount; j++) {
          await drawGesture.moveTo(
            Offset(
              stroke.pointAt(j).x.toDouble(),
              stroke.pointAt(j).y.toDouble(),
            ),
          );
        }
        await drawGesture.up();
        await tester.pumpAndSettle();
      }

      final resultHelloImage =
          controller.drawingAsImage(backgroundColor: Colors.white);

      await tester.runAsync<void>(
        additionalTime: const Duration(seconds: 5),
        () async {
          final imageAsPNG = await resultHelloImage.toPNG();
          writeImage('test/resulting_output/hello.png', imageAsPNG!);
          expect(
            compareImages('test/expected_output/hello.png', imageAsPNG),
            true,
          );
        },
      );
    });
  });
}
