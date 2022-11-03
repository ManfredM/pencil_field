import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencil_field/pencil_field.dart';

import 'test_helpers.dart';

class PencilDecorationTest {
  PencilDecorationTest({
    required this.name,
    required this.givenType,
    this.givenBackgroundColor,
    this.givenPatternColor,
    this.givenSpacing,
    this.givenNumberOfLines,
    this.givenHasFrame,
    this.givenPaintProvider,
    required this.resultFilePath,
    required this.expectedFilePath,
    required this.runner,
  });

  final String name;
  final PencilDecorationType givenType;
  final Color? givenBackgroundColor;
  final Color? givenPatternColor;
  final double? givenSpacing;
  final int? givenNumberOfLines;
  final bool? givenHasFrame;
  final PencilDecorationPaintProvider? givenPaintProvider;
  final String resultFilePath;
  final String expectedFilePath;
  final Function(PencilDecorationTest decorationTest) runner;
}

void main() {
  group('Test PencilDecoration', () {
    void paintAndSave(
      PencilDecoration decoration,
      String resultingFilePath,
      String expectedFilePath,
    ) async {
      // Paint the decoration
      PictureRecorder pictureRecorder = PictureRecorder();
      Canvas canvas = Canvas(pictureRecorder);
      decoration.paint(canvas, const Size(500, 500));

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(500, 500);
      final byteImage = await image.toByteData(format: ImageByteFormat.png);
      final imageAsPNG = byteImage!.buffer.asUint8List();
      await writeImage(resultingFilePath, imageAsPNG);

      expect(await compareImages(expectedFilePath, imageAsPNG), true);
    }

    final decorationTests = <PencilDecorationTest>[
      PencilDecorationTest(
        name: 'Chequered background with fixed spacing.',
        givenType: PencilDecorationType.chequered,
        givenBackgroundColor: Colors.white,
        givenPatternColor: Colors.lightGreen,
        givenSpacing: 35,
        resultFilePath:
            'test/resulting_output/chequered_spacing_no_frame_decoration.png',
        expectedFilePath:
            'test/expected_output/chequered_spacing_no_frame_decoration.png',
        runner: (decorationTest) async {
          final result = PencilDecoration(
            type: decorationTest.givenType,
            backgroundColor: decorationTest.givenBackgroundColor!,
            patternColor: decorationTest.givenPatternColor!,
            spacing: decorationTest.givenSpacing!,
            strokeWidth: 1,
          );
          paintAndSave(
            result,
            decorationTest.resultFilePath,
            decorationTest.expectedFilePath,
          );
        },
      ),
      PencilDecorationTest(
        name: 'Chequered background with number of lines.',
        givenType: PencilDecorationType.chequered,
        givenBackgroundColor: Colors.white,
        givenPatternColor: Colors.lightGreen,
        givenNumberOfLines: 10,
        resultFilePath:
            'test/resulting_output/chequered_number_of_lines_no_frame_decoration.png',
        expectedFilePath:
            'test/expected_output/chequered_number_of_lines_no_frame_decoration.png',
        runner: (decorationTest) async {
          final result = PencilDecoration(
            type: decorationTest.givenType,
            backgroundColor: decorationTest.givenBackgroundColor!,
            patternColor: decorationTest.givenPatternColor!,
            numberOfLines: decorationTest.givenNumberOfLines!,
            strokeWidth: 1,
          );
          paintAndSave(
            result,
            decorationTest.resultFilePath,
            decorationTest.expectedFilePath,
          );
        },
      ),
      PencilDecorationTest(
        name: 'Ruled background with number of lines.',
        givenType: PencilDecorationType.ruled,
        givenBackgroundColor: Colors.white,
        givenPatternColor: Colors.lightGreen,
        givenNumberOfLines: 10,
        resultFilePath:
            'test/resulting_output/ruled_number_of_lines_no_frame_decoration.png',
        expectedFilePath:
            'test/expected_output/ruled_number_of_lines_no_frame_decoration.png',
        runner: (decorationTest) async {
          final result = PencilDecoration(
            type: decorationTest.givenType,
            backgroundColor: decorationTest.givenBackgroundColor!,
            patternColor: decorationTest.givenPatternColor!,
            numberOfLines: decorationTest.givenNumberOfLines!,
            strokeWidth: 1,
          );
          paintAndSave(
            result,
            decorationTest.resultFilePath,
            decorationTest.expectedFilePath,
          );
        },
      ),
      PencilDecorationTest(
        name: 'Ruled background with number of lines with frame.',
        givenType: PencilDecorationType.ruled,
        givenBackgroundColor: Colors.white,
        givenPatternColor: Colors.lightGreen,
        givenNumberOfLines: 10,
        givenHasFrame: true,
        resultFilePath:
            'test/resulting_output/ruled_number_of_lines_with_frame_decoration.png',
        expectedFilePath:
            'test/expected_output/ruled_number_of_lines_with_frame_decoration.png',
        runner: (decorationTest) async {
          final result = PencilDecoration(
            type: decorationTest.givenType,
            backgroundColor: decorationTest.givenBackgroundColor!,
            patternColor: decorationTest.givenPatternColor!,
            numberOfLines: decorationTest.givenNumberOfLines!,
            hasFrame: decorationTest.givenHasFrame!,
            strokeWidth: 5,
          );
          paintAndSave(
            result,
            decorationTest.resultFilePath,
            decorationTest.expectedFilePath,
          );
        },
      ),
      PencilDecorationTest(
        name: 'Dotted background with fixed spacing.',
        givenType: PencilDecorationType.dots,
        givenBackgroundColor: Colors.white,
        givenPatternColor: Colors.lightGreen,
        givenSpacing: 18,
        givenHasFrame: true,
        resultFilePath:
            'test/resulting_output/dotted_spacing_with_frame_decoration.png',
        expectedFilePath:
            'test/expected_output/dotted_spacing_with_frame_decoration.png',
        runner: (decorationTest) async {
          final result = PencilDecoration(
            type: decorationTest.givenType,
            backgroundColor: decorationTest.givenBackgroundColor!,
            patternColor: decorationTest.givenPatternColor!,
            spacing: decorationTest.givenSpacing!,
            hasFrame: decorationTest.givenHasFrame!,
            strokeWidth: 5,
          );
          paintAndSave(
            result,
            decorationTest.resultFilePath,
            decorationTest.expectedFilePath,
          );
        },
      ),
      PencilDecorationTest(
        name: 'Dotted background with fixed spacing and custom paint provider.',
        givenType: PencilDecorationType.dots,
        givenBackgroundColor: Colors.white,
        givenPatternColor: Colors.lightGreen,
        givenSpacing: 18,
        givenHasFrame: true,
        givenPaintProvider: (row, column, paint) {
          // Every second row in red
          if (column % 2 == 0) {
            return Paint()
              ..color = Colors.redAccent
              ..strokeWidth = 5;
          }

          // And the frame in yellow with a very thick border.
          if (column == -1 && row == -1) {
            return Paint()
              ..color = Colors.yellowAccent
              ..strokeWidth = 10
              ..style = PaintingStyle.stroke;
          }

          // In all other cases use the predefined style
          return paint;
        },
        resultFilePath:
            'test/resulting_output/dotted_spacing_with_frame_custom_paint_decoration.png',
        expectedFilePath:
            'test/expected_output/dotted_spacing_with_frame_custom_paint_decoration.png',
        runner: (decorationTest) async {
          final result = PencilDecoration(
            type: decorationTest.givenType,
            backgroundColor: decorationTest.givenBackgroundColor!,
            patternColor: decorationTest.givenPatternColor!,
            spacing: decorationTest.givenSpacing!,
            hasFrame: decorationTest.givenHasFrame!,
            paintProvider: decorationTest.givenPaintProvider!,
            strokeWidth: 5,
          );
          paintAndSave(
            result,
            decorationTest.resultFilePath,
            decorationTest.expectedFilePath,
          );
        },
      ),
      PencilDecorationTest(
        name: 'no decoration',
        givenType: PencilDecorationType.blank,
        givenBackgroundColor: Colors.white,
        resultFilePath: 'test/resulting_output/blank_decoration.png',
        expectedFilePath: 'test/expected_output/blank_decoration.png',
        runner: (decorationTest) async {
          final result = PencilDecoration(
            type: decorationTest.givenType,
          );
          paintAndSave(
            result,
            decorationTest.resultFilePath,
            decorationTest.expectedFilePath,
          );
        },
      ),
    ];

    for (final decorationTest in decorationTests) {
      test(decorationTest.name, () async {
        decorationTest.runner(decorationTest);
      });
    }
  });
}
