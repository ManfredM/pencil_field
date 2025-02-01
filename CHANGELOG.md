## 0.0.1

* **Initial release**

## 0.0.2

* **DOCUMENTATION** Some corrections in a few files

## 0.0.3

* **DOCUMENTATION** Even more corrections...

## 0.1.0

* **DOCUMENTATION** Added more documentation to all functions
* **BREAKING** Removed some duplicate functions

## 0.1.1

* **DEVELOPMENT** Added automated testing to github repository
* **IMPROVEMENT** Minor changes in example

## 0.1.2

* **DEPLOYMENT** Restrict package to iOS, Android and Web

## 0.2.0

* **BUGFIX** Using PencilDecoration with padding led to wrong decoration pattern
* **BUGFIX** Using PencilController setDrawing could lead to an exception when called in write mode
* **BUGFIX** Fixed images for comparison of drawing routines
* **IMPROVEMENT** PencilDecorator can have custom callback to draw background
* **BREAKING** PencilDecorator now accepts either number of lines or a fixed spacing to draw ruled, chequered or dotted pattern
* **DOCUMENTATION** Improved example

## 0.2.1

* **BUGFIX** Changed signature of custom painter function in PencilDecoration

## 0.2.2

* **BUGFIX** Fixed bug in undo method when controller is in erase mode

## 0.3.0

* **IMPROVEMENT** A callback to provide the paint to be used for background pattern added to PencilDecoration

## 0.4.0

* **BREAKING** Removed equatable dependency
* **BREAKING** Renamed methods dealing with strokes of class PencilDrawing for better clarity.
* **IMPROVEMENT** Added many more tests
* **IMPROVEMENT** Refactoring of code for better readability
* **IMPROVEMENT** More comprehensive example is provided

## 0.4.1

* **IMPROVEMENT** Moved some functions from PencilDrawing to PencilStroke

## 0.4.2

* **IMPROVEMENT** Use bezier curve to draw PencilStroke

## 0.4.3

* **IMPROVEMENT** Instead of cubicTo quadraticBezierTo is used to achieve a smoother line

## 0.4.4

* **IMPROVEMENT** Updated to Dart 3.0

## 0.4.5

* **IMPROVEMENT** Decreased the minumim distance of a point to be added to 0.1 from 0.5. The larger number prevented some points that should have been added from being added.

## 0.4.6

* **FIX** Strokes that only have a single point are shown correctly.

## 0.4.7

* **FIX** Reduced diameter of the dot to match line width.

## 0.4.8

* **FIX** Fixed failing tests after update to Flutter 3.24.0 and Dart 3.5

## 0.4.9

* **FIX** Fixed warnings

## 0.4.10

* **FIX** Requires Flutter 3.27.3 or higher
  