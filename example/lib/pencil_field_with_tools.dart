import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:pencil_field/pencil_field.dart';

/// PencilFieldWithTools supports the following modes
enum _PencilToolType { pen, marker, eraser, radiusEraser, undo, clear }

/// [PencilFieldWithTools] provides a complete input field with different
/// tools based on the raw [PencilField].
///
/// Once the user has submitted the drawing is returned via the [onSubmitted]
/// callback
class PencilFieldWithTools extends StatefulWidget {
  const PencilFieldWithTools({
    super.key,
    required this.controller,
    this.onPencilDrawingChanged,
  });

  final PencilFieldController controller;
  final OnPencilDrawingChanged? onPencilDrawingChanged;

  @override
  State<PencilFieldWithTools> createState() => _PencilFieldWithToolsState();
}

typedef _OnToolSelectedCallback = Function(_PencilToolType, PencilPaint);

class _PencilFieldWithToolsState extends State<PencilFieldWithTools> {
  PencilPaint eraserPaint =
      PencilPaint(color: Colors.red[200]!, strokeWidth: 2.0);

  PencilPaint pencilPaint = PencilPaint(color: Colors.black, strokeWidth: 2.0);
  PencilPaint writingPaint = PencilPaint(color: Colors.black, strokeWidth: 2.0);
  double _eraserRadius = 10.0;

  void _onToolSelected(_PencilToolType type, PencilPaint newPaint) {
    setState(() {
      switch (type) {
        case _PencilToolType.pen:
        case _PencilToolType.marker:
          writingPaint = newPaint;
          widget.controller.setMode(PencilMode.write);
          pencilPaint = writingPaint;
          break;
        case _PencilToolType.eraser:
          widget.controller.setMode(PencilMode.erase);
          pencilPaint = eraserPaint;
          break;
        case _PencilToolType.radiusEraser:
          widget.controller.setMode(
            PencilMode.radiusErase,
            eraserRadius: _eraserRadius,
          );
          pencilPaint = PencilPaint(
            color: Colors.orange[300]!,
            strokeWidth: 2.0,
          );
          break;
        case _PencilToolType.clear:
          widget.controller.setDrawing(PencilDrawing(strokes: []));
          widget.controller.setMode(PencilMode.write);
          pencilPaint = writingPaint;
          widget.onPencilDrawingChanged?.call(widget.controller.drawing);
          break;
        case _PencilToolType.undo:
          widget.controller.undo();
          break;
      }
    });
  }

  void _onRadiusEraserLongPress(BuildContext context, Offset position) {
    showMenu<double>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - 200,
        position.dx + 1,
        position.dy,
      ),
      items: List.generate(11, (i) {
        final size = (i + 5).toDouble();
        final isSelected = size == _eraserRadius;
        return PopupMenuItem<double>(
          value: size,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: isSelected
                ? BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Row(
              children: [
                Container(
                  width: size * 2,
                  height: size * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange[300],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${size.toInt()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ).then((value) {
      if (value != null) {
        setState(() {
          _eraserRadius = value;
          widget.controller.setMode(
            PencilMode.radiusErase,
            eraserRadius: _eraserRadius,
          );
          pencilPaint = PencilPaint(
            color: Colors.orange[300]!,
            strokeWidth: 2.0,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: const BoxDecoration(
        color: PencilFieldColors.writePadControls,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PencilFieldTools(
              currentPaint: pencilPaint,
              currentMode: widget.controller.mode,
              onToolSelected: _onToolSelected,
              onRadiusEraserLongPress: _onRadiusEraserLongPress,
              eraserRadius: _eraserRadius,
            ),
            Container(
              decoration: const BoxDecoration(
                color: PencilFieldColors.paper,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              padding: const EdgeInsets.all(8),
              height: 400,
              child: PencilField(
                controller: widget.controller,
                pencilPaint: pencilPaint,
                onPencilDrawingChanged: widget.onPencilDrawingChanged,
                decoration: PencilDecoration(
                  type: PencilDecorationType.chequered,
                  backgroundColor: PencilFieldColors.paper,
                  // PencilFieldColors.paper,
                  patternColor: PencilFieldColors.paperPattern,
                  hasBorder: true,
                  spacing: 20,
                  strokeWidth: 1.5,
                  //padding: const EdgeInsets.all(10),
                ),
                pencilOnly: kReleaseMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PencilFieldTools extends StatelessWidget {
  _PencilFieldTools({
    required this.currentPaint,
    required this.currentMode,
    required this.onToolSelected,
    this.onRadiusEraserLongPress,
    this.eraserRadius = 10.0,
  });

  final PencilMode currentMode;
  final PencilPaint currentPaint;
  final double eraserRadius;
  final eraserPaint = PencilPaint(
    color: PencilFieldColors.eraser,
    strokeWidth: 2.0,
  );

  final markerColors = <Color>[
    PencilFieldColors.markerBlue,
    PencilFieldColors.markerGreen,
    PencilFieldColors.markerOrange,
    PencilFieldColors.markerYellow,
    PencilFieldColors.markerPurple,
    PencilFieldColors.markerRed,
  ];

  final _OnToolSelectedCallback onToolSelected;
  final void Function(BuildContext, Offset)? onRadiusEraserLongPress;
  final penColors = <Color>[
    PencilFieldColors.ink,
    PencilFieldColors.pencil,
    PencilFieldColors.pencilYellow,
    PencilFieldColors.pencilOrange,
    PencilFieldColors.pencilRed,
    PencilFieldColors.pencilPurple,
    PencilFieldColors.pencilLightBlue,
    PencilFieldColors.pencilLightGreen,
    PencilFieldColors.pencilGreen,
    PencilFieldColors.pencilBrown,
  ];

  @override
  Widget build(BuildContext context) {
    final pens = List<_ToolSelectorButton>.generate(
      penColors.length,
      (index) => _ToolSelectorButton(
        type: _PencilToolType.pen,
        onToolSelected: onToolSelected,
        pencilPaint: PencilPaint(
          color: penColors[index],
          strokeWidth: 3.0,
        ),
        currentPaint: currentPaint,
      ),
    );
    final markers = List<_ToolSelectorButton>.generate(
      markerColors.length,
      (index) => _ToolSelectorButton(
        type: _PencilToolType.marker,
        onToolSelected: onToolSelected,
        pencilPaint: PencilPaint(
          color: markerColors[index],
          strokeWidth: 12.0,
        ),
        currentPaint: currentPaint,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: SizedBox(
        height: 96,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ToolSelectorButton(
              type: _PencilToolType.clear,
              pencilPaint:
                  PencilPaint(color: PencilFieldColors.red, strokeWidth: 1.0),
              onToolSelected: onToolSelected,
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: pens),
                Row(children: markers),
              ],
            ),
            const Spacer(),
            _ToolSelectorButton(
              type: _PencilToolType.eraser,
              pencilPaint: eraserPaint,
              onToolSelected: onToolSelected,
              currentPaint: currentPaint,
            ),
            _ToolSelectorButton(
              type: _PencilToolType.radiusEraser,
              pencilPaint: PencilPaint(
                color: Colors.orange[300]!,
                strokeWidth: 2.0,
              ),
              onToolSelected: onToolSelected,
              currentPaint: currentPaint,
              onLongPress: onRadiusEraserLongPress,
              eraserRadius: eraserRadius,
            ),
            _ToolSelectorButton(
              type: _PencilToolType.undo,
              pencilPaint: eraserPaint,
              onToolSelected: onToolSelected,
            ),
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
    this.currentPaint,
    this.onLongPress,
    this.eraserRadius,
  });

  final PencilPaint? currentPaint;
  final _OnToolSelectedCallback onToolSelected;
  final PencilPaint pencilPaint;
  final _PencilToolType type;
  final void Function(BuildContext, Offset)? onLongPress;
  final double? eraserRadius;

  @override
  Widget build(BuildContext context) {
    bool isActiveTool = false;
    if (currentPaint != null) {
      if (currentPaint!.paint.color.value == pencilPaint.paint.color.value) {
        isActiveTool = true;
      }
    }

    late Widget icon;
    switch (type) {
      case _PencilToolType.pen:
        icon = const Icon(LineAwesomeIcons.pen_solid);
        break;
      case _PencilToolType.marker:
        icon = const Icon(LineAwesomeIcons.marker_solid);
        break;
      case _PencilToolType.eraser:
        icon = const Icon(LineAwesomeIcons.eraser_solid);
        break;
      case _PencilToolType.radiusEraser:
        // Show a circle matching the size shown in the picker dialog
        final displaySize = (eraserRadius ?? 10) * 2;
        final circleColor =
            isActiveTool ? Colors.white : pencilPaint.paint.color;
        icon = SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: Container(
              width: displaySize.clamp(6.0, 24.0),
              height: displaySize.clamp(6.0, 24.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: circleColor, width: 2.5),
              ),
            ),
          ),
        );
        break;
      case _PencilToolType.clear:
        icon = const Icon(LineAwesomeIcons.trash_solid);
        break;
      case _PencilToolType.undo:
        icon = const Icon(LineAwesomeIcons.undo_solid);
        break;
    }

    final button = IconButton(
      icon: icon,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(
          isActiveTool ? Colors.white : pencilPaint.paint.color,
        ),
        backgroundColor: WidgetStateProperty.all<Color>(
          isActiveTool ? pencilPaint.paint.color : PencilFieldColors.paper,
        ),
        overlayColor: WidgetStateProperty.all<Color>(
          isActiveTool
              ? Colors.white.withAlpha(64)
              : pencilPaint.paint.color.withAlpha(64),
        ),
      ),
      onPressed: () => onToolSelected(type, pencilPaint),
    );

    if (onLongPress != null) {
      return GestureDetector(
        onLongPressStart: (details) {
          onLongPress!(context, details.globalPosition);
        },
        child: button,
      );
    }
    return button;
  }
}

class PencilFieldColors {
  PencilFieldColors._();

  static const Color appBarColor = Color(0xFF796E84);
  static const Color blue = Color(0xFF4094CF);
  static const Color eraser = Color(0xFFEF9A9A);
  static const Color green = Color(0xFFA7DF31);
  static const Color ink = Color(0xFF0500FF);
  static const Color markerBlue = Color(0x804094CF);
  static const Color markerGreen = Color(0x80A7DF31);
  static const Color markerOrange = Color(0x80F3983B);
  static const Color markerPurple = Color(0x80BB6BD9);
  static const Color markerRed = Color(0x80E85476);
  static const Color markerYellow = Color(0x80EADE00);
  static const Color orange = Color(0xFFF3983B);
  static const Color paper = Color(0xFFFFFEF4);
  static const Color paperPattern = Colors.black12;
  static const Color pencil = Color(0xCC3C3C3E);
  static const Color pencilBrown = Color(0xFFB68458);
  static const Color pencilGreen = Color(0xFF2F661A);
  static const Color pencilLightBlue = Color(0xFF83E3F7);
  static const Color pencilLightGreen = Color(0xFF7BDC44);
  static const Color pencilOrange = Color(0xFFDB762C);
  static const Color pencilPurple = Color(0xFF9E4FD1);
  static const Color pencilRed = Color(0xFFE93732);
  static const Color pencilYellow = Color(0xFFCFBF1C);
  static const Color purple = Color(0xFFBB6BD9);
  static const Color red = Color(0xFFE85476);
  static const Color transparentPaper = Color(0xFFFFFEF4); //Color(0xCCFFFEF4);
  static const Color writePadBackground = Color(0xFF667D8B);
  static const Color writePadControls = Color(0xFFB3BDBF);
  static const Color yellow = Color(0xFFEADE00);
}
