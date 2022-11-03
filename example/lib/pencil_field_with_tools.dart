import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:pencil_field/pencil_field.dart';

class PencilFieldWithTools extends StatefulWidget {
  final PencilFieldController controller;
  final OnPencilDrawingChanged? onPencilDrawingChanged;

  const PencilFieldWithTools({
    super.key,
    required this.controller,
    this.onPencilDrawingChanged,
  });

  @override
  State<PencilFieldWithTools> createState() => _PencilFieldWithToolsState();
}

//typedef _OnModeSelectedCallback = Function(PencilMode);
typedef _OnToolSelectedCallback = Function(PencilToolType, PencilPaint);

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
              onToolSelected: _onToolSelected,
              //onModeSelected: _onModeSelected,
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
                  hasFrame: true,
                  spacing: 20,
                  lineWidth: 1,
                  padding: const EdgeInsets.all(10),
                  paintProvider: (column, row, paint) {
                    if (row == 10 || column == 10) {
                      paint.color = Colors.red;
                      return paint;
                    }
                    return paint;
                  },
                ),
                pencilOnly: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onToolSelected(PencilToolType type, PencilPaint newPaint) {
    setState(() {
      switch (type) {
        case PencilToolType.pen:
        case PencilToolType.marker:
          writingPaint = newPaint;
          widget.controller.setMode(PencilMode.write);
          pencilPaint = writingPaint;
          break;
        case PencilToolType.eraser:
          widget.controller.setMode(PencilMode.erase);
          pencilPaint = eraserPaint;
          break;
      }
    });
  }

  void _onPrintJSON() {
    setState(() {
      widget.controller.undo();
    });

    //log(widget.controller.drawing.toJson().toString());
  }
}

enum PencilToolType { pen, marker, eraser }

class _PencilFieldTools extends StatelessWidget {
  _PencilFieldTools({
    required this.currentPaint,
    required this.currentMode,
    required this.onToolSelected,
    //required this.onModeSelected,
    required this.onPrintJSON,
  });

  final PencilPaint currentPaint;
  final PencilMode currentMode;
  final _OnToolSelectedCallback onToolSelected;

  //final _OnModeSelectedCallback onModeSelected;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            _ToolSelectorButton(
              type: PencilToolType.pen,
              pencilPaint: blackPaint,
              onToolSelected: onToolSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _ToolSelectorButton(
              type: PencilToolType.pen,
              pencilPaint: orangePaint,
              onToolSelected: onToolSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _ToolSelectorButton(
              type: PencilToolType.pen,
              pencilPaint: bluePaint,
              onToolSelected: onToolSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _ToolSelectorButton(
              type: PencilToolType.pen,
              pencilPaint: redPaint,
              onToolSelected: onToolSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _ToolSelectorButton(
              type: PencilToolType.pen,
              pencilPaint: greenPaint,
              onToolSelected: onToolSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _ToolSelectorButton(
              type: PencilToolType.marker,
              pencilPaint: markerYellowPaint,
              onToolSelected: onToolSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 8),
            _ToolSelectorButton(
              type: PencilToolType.marker,
              pencilPaint: markerBluePaint,
              onToolSelected: onToolSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 16),
            _ToolSelectorButton(
              type: PencilToolType.eraser,
              pencilPaint: eraserPaint,
              onToolSelected: onToolSelected,
              currentPaint: currentPaint,
            ),
            const SizedBox(width: 16),
            _DebugButton(name: "JSON", onPressed: onPrintJSON),
          ],
        ),
      ),
    );
  }
}

class _ToolSelectorButton extends StatelessWidget {
  const _ToolSelectorButton({
    required this.type,
    required this.onToolSelected,
    required this.pencilPaint,
    required this.currentPaint,
  });

  final PencilToolType type;
  final _OnToolSelectedCallback onToolSelected;
  final PencilPaint pencilPaint;
  final PencilPaint currentPaint;

  @override
  Widget build(BuildContext context) {
    late Icon icon;
    switch (type) {
      case PencilToolType.pen:
        icon = const Icon(LineAwesomeIcons.pen);
        break;
      case PencilToolType.marker:
        icon = const Icon(LineAwesomeIcons.marker);
        break;
      case PencilToolType.eraser:
        icon = const Icon(LineAwesomeIcons.eraser);
        break;
    }

    final bool isActiveColor = currentPaint == pencilPaint;
    return IconButton(
      icon: icon,
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
      onPressed: () => onToolSelected(type, pencilPaint),
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
