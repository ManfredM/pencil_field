import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pencil_field/pencil_field.dart';

/// Test data. It's a very simple drawing that is used for testing. This test
/// data should be expanded with some more complex examples. However, they
/// must be loaded from a file due to the amount of data.
///
/// (0,0)             (20, 0)               [40,0]
///   |                  |                   /
///   |    {10,5}-------------------{30,5}  /
///   |    [10,10]------------------[30, 10]
///   |                  |
///   |                  |
/// (0, 20)-----------(20,20)
///
/// (givenPencilStroke1), [givenPencilStroke2] are pencil strokes
/// {givenEraserStroke1} is an eraser stroke (will delete (givenPencilStroke1)
///    when used)
final givenPaint = PencilPaint(color: Colors.black, strokeWidth: 2);

// Points as defined above
const givenPoint1 = Point(0, 0);
const givenPoint2 = Point(0, 20);
const givenPoint3 = Point(20, 20);
const givenPoint4 = Point(20, 0);
const givenPoint5 = Point(10, 10);
const givenPoint6 = Point(30, 10);
const givenPoint7 = Point(40, 0);
const givenPoint8 = Point(10, 5);
const givenPoint9 = Point(30, 5);
const givenPoint10 = Point(20.1, 20.1);

final givenPencilStroke1 = PencilStroke(
  points: const [
    givenPoint1,
    givenPoint2,
    givenPoint3,
    givenPoint4,
  ],
  bezierDistance: 1,
  pencilPaint: givenPaint,
);
const givenPencilStroke1Size = Size(20, 20);
const int givenPencilStroke1PointCount = 4;

final givenPencilStroke2 = PencilStroke(
  points: const [
    givenPoint5,
    givenPoint6,
    givenPoint7,
  ],
  bezierDistance: 1,
  pencilPaint: givenPaint,
);
const int givenPencilStroke2PointCount = 3;
const givenPencilStroke2Size = Size(40, 10);

final givenEraserStroke1 = PencilStroke(
  points: const [
    givenPoint8,
    givenPoint9,
  ],
  bezierDistance: 1,
  pencilPaint: givenPaint,
);

// Total size of a drawing consisting of strokes 1 and 2
const givenDrawingSize = Size(40, 20);

/// Points needed to writer the world "Hallo".
const pointsForHello = [
  // H
  '29.5;31.0, 29.5;31.5, 29.5;33.0, 29.5;36.0, 29.5;40.5, 29.5;45.5, 29.5;52.0, 29.5;58.0, 29.5;65.5, 29.5;72.5, 29.5;78.5, 29.5;85.0, 29.5;91.5, 29.5;97.0, 29.5;106.0, 30.0;109.0, 30.0;109.5',
  '63.0;35.5, 63.0;37.5, 63.0;45.0, 63.0;49.5, 63.0;58.0, 63.0;64.0, 63.0;76.0, 63.0;81.5, 63.0;86.0, 63.0;89.0, 63.0;91.5, 63.0;94.5, 63.0;97.5, 63.0;99.5, 63.0;102.0',
  '30.0;73.5, 32.0;73.5, 35.5;73.5, 39.0;73.5, 41.5;73.5, 46.0;73.5, 49.5;73.5, 56.0;73.0, 59.5;72.5, 64.5;72.0, 66.5;72.0, 69.0;71.5, 69.5;71.5, 69.5;71.0',

  // a
  '96.5;73.0, 96.5;72.5, 95.5;72.0, 94.0;70.5, 91.0;69.0, 89.0;67.5, 86.5;66.5, 85.5;66.0, 84.5;66.0, 83.5;66.0, 82.5;66.0, 81.5;66.0, 80.5;67.0, 80.0;67.5, 80.0;68.5, 80.0;69.5, 80.0;70.0, 80.0;71.0, 80.0;71.5, 80.0;72.5, 80.0;73.5, 80.0;74.5, 80.0;76.5, 80.5;78.0, 81.0;79.5, 82.0;82.5, 82.5;84.0, 83.5;85.0, 84.0;85.5, 85.0;86.0, 85.5;86.0, 86.5;86.5, 88.0;86.5, 89.5;87.0, 91.5;87.0, 93.5;87.0, 95.0;87.0, 96.0;87.0, 98.5;85.5, 100.0;83.5, 101.5;81.0, 103.0;79.0, 104.0;76.5, 105.0;74.0, 105.0;72.0, 105.0;69.5, 105.0;67.5, 105.0;66.0, 105.0;65.0, 105.0;64.0, 104.5;64.0, 104.5;64.5, 104.5;65.5, 104.5;67.0, 104.5;68.5, 104.5;70.0, 104.5;72.0, 104.5;74.0, 104.5;76.5, 104.5;80.0, 105.0;87.0, 105.5;90.0, 106.5;93.0, 107.0;94.0, 107.5;94.5, 108.0;94.5',

  // l
  '124.0;37.0, 124.0;40.5, 124.0;44.5, 124.0;48.5, 124.0;52.5, 124.0;56.5, 124.0;64.5, 124.0;69.0, 124.0;77.0, 124.5;80.5, 125.0;86.0, 125.5;88.0, 126.0;90.5, 126.0;91.5, 126.5;92.0, 127.0;92.0, 128.5;92.5, 130.5;92.5, 137.0;93.0, 144.5;92.5, 149.0;90.0, 150.0;89.5, 150.5;89.0',

  // l
  '155.5;29.0, 155.5;29.5, 155.5;31.0, 155.5;33.5, 155.5;37.0, 155.5;39.5, 155.5;43.0, 155.5;46.5, 155.5;49.5, 155.5;53.0, 155.5;57.0, 155.5;60.5, 155.5;64.0, 155.5;67.0, 155.5;70.0, 156.0;73.5, 156.5;76.5, 157.0;78.5, 157.5;80.0, 157.5;81.0, 157.5;81.5, 158.0;82.0, 158.5;83.0, 159.0;85.0, 160.0;87.0, 160.5;88.5, 161.5;89.5, 161.5;90.5, 162.0;90.5, 162.5;91.0, 163.5;91.0, 165.0;91.0, 167.0;90.5, 170.0;90.0, 173.0;89.0, 174.5;88.0, 176.0;87.5, 176.5;87.0',

  //o
  '205.5;66.5, 203.5;66.0, 200.5;65.0, 198.5;65.0, 195.0;65.0, 194.0;65.0, 193.0;65.0, 192.0;65.0, 190.5;66.0, 189.5;67.0, 189.0;67.5, 189.0;68.5, 188.0;71.5, 187.5;74.0, 187.0;78.0, 187.0;80.0, 187.0;84.5, 187.0;87.0, 187.0;90.5, 187.0;92.0, 188.0;93.0, 189.0;94.5, 189.5;94.5, 190.5;95.0, 192.0;95.0, 198.0;95.5, 201.0;95.5, 206.5;95.5, 208.5;95.0, 211.5;92.0, 213.0;90.0, 216.5;86.0, 217.5;84.0, 218.5;80.5, 219.0;77.5, 219.0;75.5, 219.0;73.5, 218.5;72.0, 217.5;70.5, 215.0;68.5, 213.5;68.0, 210.0;68.0, 207.5;68.0, 202.0;68.0',
];

List<PencilStroke> generateHelloStrokes() {
  final pencilPaint = PencilPaint(strokeWidth: 2, color: Colors.black);
  final pencilStrokes = <PencilStroke>[];

  // Transform the string into points.
  for (final strokePoints in pointsForHello) {
    final pointsAsText = strokePoints.split(',');
    final points = <Point>[];
    for (final pointAsText in pointsAsText) {
      final xy = pointAsText.split(';');
      final point = Point(double.parse(xy[0]), double.parse(xy[1]));
      points.add(point);
    }
    pencilStrokes.add(PencilStroke(
      points: points,
      bezierDistance: 1,
      pencilPaint: pencilPaint,
    ));
  }

  return pencilStrokes;
}

void writeImage(String fileName, Uint8List image) {
  File file = File(fileName);
  file.writeAsBytesSync(image, flush: true);
}

/*Future<bool>*/
bool compareImages(String expectedImagePath, Uint8List createdImage) {
  File file = File(expectedImagePath);
  final Uint8List expectedImage = file.readAsBytesSync();
  return listEquals(createdImage, expectedImage);
}
