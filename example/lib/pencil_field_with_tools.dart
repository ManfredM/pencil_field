import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pencil_field/pencil_field.dart';

class PencilFieldWithTools extends StatefulWidget {
  final PencilFieldController controller;
  final OnPencilDrawingChanged? onPencilDrawingChanged;

  const PencilFieldWithTools(
      {Key? key, required this.controller, this.onPencilDrawingChanged})
      : super(key: key);

  @override
  State<PencilFieldWithTools> createState() => _PencilFieldWithToolsState();
}

typedef _OnModeSelectedCallback = Function(PencilMode);
typedef _OnPaintSelectedCallback = Function(PencilPaint);

class _PencilFieldWithToolsState extends State<PencilFieldWithTools> {
  PencilPaint pencilPaint = PencilPaint(color: Colors.black, strokeWidth: 2.0);
  PencilPaint writingPaint = PencilPaint(color: Colors.black, strokeWidth: 2.0);
  PencilPaint eraserPaint =
      PencilPaint(color: Colors.red[200]!, strokeWidth: 2.0);

  //PencilMode mode = PencilMode.write;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black38,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: Colors.grey[200]!,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PencilFieldTools(
              currentPaint: pencilPaint,
              currentMode: widget.controller.mode,
              onPaintSelected: _onPaintSelected,
              onModeSelected: _onModeSelected,
              onPrintJSON: _onPrintJSON,
            ),
            Expanded(
              child: PencilField(
                controller: widget.controller,
                pencilPaint: pencilPaint,
                onPencilDrawingChanged: widget.onPencilDrawingChanged,
                decoration: PencilDecoration(
                  type: PencilDecorationType.chequered,
                  backgroundColor: Colors.white,
                  patternColor: Colors.grey[300]!,
                  numberOfLines: 10,
                  lineWidth: 2,
                  padding: const EdgeInsets.all(10),
                ),
                pencilOnly: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPaintSelected(PencilPaint newPaint) {
    setState(() {
      writingPaint = newPaint;
      widget.controller.setMode(PencilMode.write);
      pencilPaint = writingPaint;
    });
  }

  void _onModeSelected(PencilMode newMode) {
    setState(() {
      widget.controller.setMode(PencilMode.erase);
      pencilPaint = eraserPaint;
    });
  }

  void _onPrintJSON() {
    log(widget.controller.drawing.toJson().toString());
  }
}

class _PencilFieldTools extends StatelessWidget {
  final PencilPaint currentPaint;
  final PencilMode currentMode;
  final _OnPaintSelectedCallback onPaintSelected;
  final _OnModeSelectedCallback onModeSelected;
  final VoidCallback onPrintJSON;

  final blackPaint = PencilPaint(
    color: Colors.black,
    strokeWidth: 2.0,
  );
  final orangePaint = PencilPaint(
    color: Colors.orange,
    strokeWidth: 2.0,
  );
  final greenPaint = PencilPaint(
    color: Colors.green,
    strokeWidth: 2.0,
  );
  final redPaint = PencilPaint(
    color: Colors.red,
    strokeWidth: 2.0,
  );
  final bluePaint = PencilPaint(
    color: Colors.blue,
    strokeWidth: 2.0,
  );
  final markerYellowPaint = PencilPaint(
    color: Colors.yellowAccent.withAlpha(128),
    strokeWidth: 10.0,
  );
  final markerBluePaint = PencilPaint(
    color: Colors.blueAccent.withAlpha(128),
    strokeWidth: 10.0,
  );
  final eraserPaint = PencilPaint(
    color: Colors.red[200]!,
    strokeWidth: 2.0,
  );

  _PencilFieldTools({
    Key? key,
    required this.currentPaint,
    required this.currentMode,
    required this.onPaintSelected,
    required this.onModeSelected,
    required this.onPrintJSON,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            _PaintSelectorButton(
              pencilPaint: blackPaint,
              onPaintSelected: onPaintSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _PaintSelectorButton(
              pencilPaint: orangePaint,
              onPaintSelected: onPaintSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _PaintSelectorButton(
              pencilPaint: bluePaint,
              onPaintSelected: onPaintSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _PaintSelectorButton(
              pencilPaint: redPaint,
              onPaintSelected: onPaintSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _PaintSelectorButton(
              pencilPaint: greenPaint,
              onPaintSelected: onPaintSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _PaintSelectorButton(
              pencilPaint: markerYellowPaint,
              onPaintSelected: onPaintSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _PaintSelectorButton(
              pencilPaint: markerBluePaint,
              onPaintSelected: onPaintSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 16),
            _ModeSelectorButton(
              name: 'eraser',
              mode: PencilMode.erase,
              onModeSelected: onModeSelected,
              isActiveMode: currentMode == PencilMode.erase,
            ),
            const SizedBox(width: 16),
            _DebugButton(name: "JSON", onPressed: onPrintJSON),
          ],
        ),
      ),
    );
  }
}

class _PaintSelectorButton extends StatelessWidget {
  final PencilPaint pencilPaint;
  final _OnPaintSelectedCallback onPaintSelected;
  final PencilPaint currentPaint;

  const _PaintSelectorButton({
    Key? key,
    required this.pencilPaint,
    required this.onPaintSelected,
    required this.currentPaint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isActiveColor = currentPaint == pencilPaint;
    return IconButton(
      icon: const Icon(Icons.edit),
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(
          isActiveColor ? Colors.white : pencilPaint.paint.color,
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          isActiveColor ? pencilPaint.paint.color : Colors.white,
        ),
        overlayColor: MaterialStateProperty.all<Color>(
          isActiveColor
              ? Colors.white.withAlpha(64)
              : pencilPaint.paint.color.withAlpha(64),
        ),
      ),
      onPressed: () => onPaintSelected(pencilPaint),
    );
  }
}

class _ModeSelectorButton extends StatelessWidget {
  final String name;
  final PencilMode mode;
  final _OnModeSelectedCallback onModeSelected;
  final bool isActiveMode;

  const _ModeSelectorButton({
    Key? key,
    required this.name,
    required this.mode,
    required this.onModeSelected,
    required this.isActiveMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(
          isActiveMode ? Colors.white : Colors.red[200]!,
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          isActiveMode ? Colors.red[200]! : Colors.white,
        ),
        overlayColor: MaterialStateProperty.all<Color>(
          isActiveMode
              ? Colors.white.withAlpha(64)
              : Colors.red[200]!.withAlpha(64),
        ),
        //foregroundColor: MaterialStateProperty.all<Color>(color),
      ),
      onPressed: () => onModeSelected(mode),
      child: Text(name),
    );
  }
}

class _DebugButton extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;

  const _DebugButton({
    Key? key,
    required this.name,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
        overlayColor:
            MaterialStateProperty.all<Color>(Colors.white.withAlpha(64)),
      ),
      onPressed: onPressed,
      child: Text(name),
    );
  }
}
