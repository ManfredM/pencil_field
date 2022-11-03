import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencil_field/pencil_field.dart';

void main() {
  group('Test PencilPaint', () {
    test('JSON encoding and decoding', () {
      PencilPaint givenPencilPaint =
          PencilPaint(color: Colors.black, strokeWidth: 1);

      final encodedPencilPaint = givenPencilPaint.toJson();
      final decodedPencilPaint = PencilPaint.fromJson(encodedPencilPaint);

      expect(
        givenPencilPaint.paint.color,
        decodedPencilPaint.paint.color,
      );
      expect(
        givenPencilPaint.paint.strokeWidth,
        decodedPencilPaint.paint.strokeWidth,
      );
    });
  });
}
