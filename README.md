<h1 align="center">FLUTTER PENCIL FIELD</h1>

# pencil_field
Widget for pencil / stylus input on different devices and platforms. This widget is intended
for any freehand input like signatures or drawings.

<p align="center">
    <img src="https://raw.githubusercontent.com/ManfredM/pencil_field/master/images/pencil_field_demo.png" alt="example" width="400"/>
</p>
<br>

## How to use
Just create PencilField widget and embedd it into your page:
```dart
PencilField(
  controller: widget.controller,
  pencilPaint: pencilPaint,
  onPencilDrawingChanged: widget.onPencilDrawingChanged,
  decoration: PencilDecoration(
    type: PencilDecorationType.chequered,
    backgroundColor: Colors.white,
    patternColor: Colors.grey[300]!,
    numberOfLines: 10,
    strokeWidth: 2,
    padding: const EdgeInsets.all(10),
  ),
  pencilOnly: true,
)
 ```

And resulting input can be displayed like so. As everything is stored in vector format scaling (e.g. for creating previews) is easy:
```dart
PencilDisplay(
  pencilDrawing: widget.controller.drawing.scale(
    scale: scale,
  ),
  decoration: PencilDecoration(backgroundColor: Colors.white),
)
 ```

## Features
<br>

### PencilField / PencilFieldController
The actual widget that provides the capability to capture and store freehand / pencil input. Each PencilField requires a controller that builds the bridge between the widget and PencilDrawing that stores the input.


### PencilDrawing
PencilDrawing stores the actual content captured by PencilField. You can store and retrieve this data in a versioned format, so that future version of PencilField can load old data.

### Example
A full example is provided. This example shows how to use PencilField and its litte sibling PencilDisplay. It also shows how to define pens for input and interactions like erase, undo and clear.
<br>

## Upcoming features
- Additional eraser that only erases strokes within a circle
- Pan support for the input widget and the display widget
- Pinch support for the display widget
- Input widget decoration that supports images as background