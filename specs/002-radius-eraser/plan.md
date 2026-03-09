# Implementation Plan: Radius-Based Sweep Eraser

**Branch**: `002-radius-eraser` | **Date**: 2026-03-09 | **Spec**: [spec.md](file:///Users/manfred/Development/Projects/pencil_field/specs/002-radius-eraser/spec.md)

## Summary

Add a new eraser mode (`PencilMode.radiusErase`) that erases stroke **segments** falling within a configurable radius of the eraser path, rather than erasing whole strokes by line intersection. The sweep area is modeled as the union of circles along the eraser path — checking whether each stroke point is within `radius` distance of any eraser path segment. Strokes partially covered are split into independent sub-strokes; fully covered strokes are removed entirely. Visual feedback shows the eraser radius and dims affected segments in real time.

## Technical Context

**Language/Version**: Dart ≥3.0.0 / Flutter ≥3.27.3  
**Primary Dependencies**: Flutter SDK only (no external packages)  
**Storage**: N/A (in-memory; JSON serialization already exists for `PencilDrawing`)  
**Testing**: `flutter_test` — existing tests in `test/` with widget tests (`field_test.dart`) and unit tests (`stroke_test.dart`, `drawing_test.dart`)  
**Target Platform**: iOS, Android, Web  
**Project Type**: Flutter package (single library)  
**Performance Goals**: 60fps rendering during erasing for drawings up to 100 strokes  
**Constraints**: No external dependencies allowed; all geometry is computed with `dart:math`

## Project Structure

### Source Code

```text
lib/
├── pencil_field.dart         # barrel export (no changes needed)
└── src/
    ├── controller.dart       # MODIFY: add radiusErase mode + sweep logic
    ├── stroke.dart           # MODIFY: add pointWithinDistance(), splitByRadius()
    ├── field.dart            # MODIFY: render radius indicator, handle new mode
    ├── drawing.dart          # no changes expected
    ├── decoration.dart       # no changes
    └── paint.dart            # no changes

test/
├── stroke_test.dart          # MODIFY: add distance + split tests
├── controller_test.dart      # MODIFY: add radius eraser controller unit tests
├── field_test.dart           # MODIFY: add widget test for radius erase
└── test_helpers.dart         # MODIFY: add helper strokes for radius tests
```

---

## Proposed Changes

### Component 1: PencilMode Enum

#### [MODIFY] [controller.dart](file:///Users/manfred/Development/Projects/pencil_field/lib/src/controller.dart)

Add `radiusErase` to the `PencilMode` enum:

```diff
-enum PencilMode { write, erase }
+enum PencilMode { write, erase, radiusErase }
```

This preserves backward compatibility — existing code using `PencilMode.erase` is unaffected.

---

### Component 2: Geometry — Point-to-Segment Distance & Stroke Splitting

#### [MODIFY] [stroke.dart](file:///Users/manfred/Development/Projects/pencil_field/lib/src/stroke.dart)

Add two new methods to `PencilStroke`:

**`pointToSegmentDistance(Point p, Point segStart, Point segEnd)`** (static)

- Computes perpendicular distance from point `p` to the line segment `segStart→segEnd`.
- Uses vector projection clamped to [0,1] to handle segment endpoints.
- Returns `double` distance.

**`splitByRadius({required List<Point> eraserPoints, required double radius})`**

- Iterates over this stroke's points.
- For each point, checks if it's within `radius` of **any** eraser path segment (using `pointToSegmentDistance`).
- Groups consecutive "surviving" points into contiguous runs.
- Returns a `List<PencilStroke>` — one new stroke per contiguous surviving run.
- Each new stroke inherits `pencilPaint` and `bezierDistance` from the original.
- If all points survive → returns `[this]` (no change).
- If no points survive → returns `[]` (fully erased).

---

### Component 3: Controller — Radius Erase Logic

#### [MODIFY] [controller.dart](file:///Users/manfred/Development/Projects/pencil_field/lib/src/controller.dart)

Add new state and methods for the radius eraser:

**New state fields:**

- `double _eraserRadius` — configurable radius (default: `10.0`)
- `PencilDrawing? _preRadiusEraseSnapshot` — snapshot of the drawing before the current gesture (for undo)

**`setMode(PencilMode mode, {double eraserRadius})`**

- Extend the existing method with an optional `eraserRadius` parameter (only used when `mode == PencilMode.radiusErase`).
- When entering `radiusErase`: initialize the eraser stroke and take a snapshot of `_drawing`.
- Invalid radius (≤0) triggers a debug assertion.

**`addPointToPath(Offset offset)` — add `radiusErase` case:**

- Append point to `_eraserStroke`.
- Perform incremental sweep: for the **last segment** of the eraser path, check all current strokes.
- For each stroke, call `splitByRadius` with the full eraser path so far and the radius.
- Replace the stroke in `_drawing` with its split results.
- Track which strokes are "dimmed" (partially or fully within sweep).

**`endPath()` — add `radiusErase` case:**

- Finalize the erase: the drawing is already modified incrementally.
- Push `_preRadiusEraseSnapshot` onto the undo stack so the whole gesture can be undone.
- Clear eraser state.

**`undo()` — extend for radius erase:**

- If the last undo entry is a radius-erase snapshot, restore the full drawing from it.
- The undo stack will store both individual strokes (from line-intersection eraser) and full snapshots (from radius eraser).

> [!IMPORTANT]
> **Undo architecture**: The existing undo stores individual deleted strokes. For the radius eraser, we need to store the **entire pre-erase drawing state** because stroke splitting creates new strokes that don't have a simple reverse operation. The plan introduces a `_undoActions` list of sealed class entries (`UndoStrokeRestore` for line erase, `UndoDrawingSnapshot` for radius erase) to handle both cleanly.

---

### Component 4: Visual Feedback — Radius Indicator & Dimming

#### [MODIFY] [field.dart](file:///Users/manfred/Development/Projects/pencil_field/lib/src/field.dart)

**In `_PencilFieldPainter.paint()`:**

- When mode is `radiusErase` and eraser has points, draw a semi-transparent circle at the last eraser point with the configured radius.

**In `PencilFieldController.draw()`:**

- For `radiusErase` mode: strokes that have been modified by the sweep are already reflected in `_drawing` (the split happens incrementally). Dimming is handled the same way as the existing eraser — strokes marked for change get reduced alpha.

---

### Component 5: PencilField Widget — Input Handling

#### [MODIFY] [field.dart](file:///Users/manfred/Development/Projects/pencil_field/lib/src/field.dart)

**In `_PencilFieldState`:**

- The `Listener` callbacks (`onPointerDown`, `onPointerMove`, `onPointerUp`) already delegate to `controller.startPath()`, `addPointToPath()`, `endPath()`. No structural changes needed — the controller handles the mode internally.
- The `acceptInput()` check works the same for all modes.

---

## Undo Architecture Detail

```dart
/// Sealed class for undo actions
sealed class PencilUndoAction {}

/// Restoring a single deleted stroke (existing line-intersection erase)
class UndoStrokeRestore extends PencilUndoAction {
  final PencilStroke stroke;
  UndoStrokeRestore(this.stroke);
}

/// Restoring the entire drawing snapshot (radius erase)
class UndoDrawingSnapshot extends PencilUndoAction {
  final PencilDrawing drawing;
  UndoDrawingSnapshot(this.drawing);
}
```

The `_undoStrokes` field is replaced with `List<PencilUndoAction> _undoActions`. The existing `undo()` for line-intersection mode pops a `UndoStrokeRestore` and adds the stroke back. For radius mode, it pops a `UndoDrawingSnapshot` and replaces `_drawing` entirely.

> [!WARNING]
> **Breaking change**: The internal `_undoStrokes` field changes type. However, it is private and not exposed in the API, so this is **not a public API breaking change**. Existing users calling `controller.undo()` and `controller.clear()` will see no change in behavior.

---

## Verification Plan

### Automated Tests

All tests run with:

```bash
cd /Users/manfred/Development/Projects/pencil_field && flutter test
```

#### 1. Unit tests — `PencilStroke` geometry (`test/stroke_test.dart`)

New test group: **"Point-to-segment distance"**

- Point on the segment → distance 0
- Point perpendicular to segment midpoint → correct distance
- Point beyond segment endpoint → distance to nearest endpoint
- Degenerate segment (start == end) → distance to point

New test group: **"Stroke splitting by radius"**

- Eraser path misses stroke entirely → returns original stroke unchanged
- Eraser path covers entire stroke → returns empty list
- Eraser path crosses middle of stroke → returns two sub-strokes
- Eraser path covers one end → returns one shorter stroke
- Single-point stroke within radius → returns empty list
- Single-point stroke outside radius → returns original
- Split strokes preserve paint and bezier distance

#### 2. Unit tests — `PencilFieldController` radius erase (`test/controller_test.dart`)

New test group: **"Radius erase mode"**

- Enter radiusErase mode → mode is set, eraser state initialized
- Draw strokes, enter radiusErase, sweep across one → affected stroke is split/removed
- Undo after radius erase → original drawing restored
- Multiple radius erase gestures + multiple undos → each gesture undone independently
- Clear after radius erase → drawing and undo history emptied
- Switch between erase and radiusErase → each mode uses its own logic

#### 3. Widget tests — `PencilField` radius erase integration (`test/field_test.dart`)

New test: **"Test radius erasing on widget"**

- Draw strokes via gesture simulation
- Set controller to `radiusErase` mode with a specific radius
- Simulate an erase gesture across part of a stroke
- Verify stroke count changes (original stroke replaced by split strokes or removed)
- Undo and verify restoration

#### 4. Existing tests — Regression

Run all existing tests to verify no regressions:

```bash
cd /Users/manfred/Development/Projects/pencil_field && flutter test
```

The existing tests for `PencilMode.erase` (line-intersection) in `field_test.dart` must continue to pass unchanged.

### Manual Verification

Manual testing is recommended for visual feedback (radius indicator rendering). The example app in `/example` can be extended with a radius eraser toggle, but this is out of scope for the initial implementation. The user can verify visual behavior by running:

```bash
cd /Users/manfred/Development/Projects/pencil_field/example && flutter run
```

And adding a temporary button to switch to `PencilMode.radiusErase`.
