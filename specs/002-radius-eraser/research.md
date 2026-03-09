# Research: Radius-Based Sweep Eraser

## Decision 1: Sweep Area Geometry

**Decision**: Model the sweep area as the union of capsule shapes (stadium shapes) between consecutive eraser path points. Check point-in-sweep by computing the shortest distance from each stroke point to each eraser path segment.

**Rationale**: This is geometrically equivalent to "sweeping a circle of radius R along the path" but is computationally efficient — O(N × M) where N = stroke points and M = eraser segments. The `pointToSegmentDistance` operation uses simple vector projection, requiring only `dart:math` (no external packages).

**Alternatives considered**:

- **Polygon-based sweep outline**: Compute the actual outline polygon of the swept circle and use point-in-polygon tests. More complex, harder to compute (requires offset curves and arc approximations), and slower for incremental updates.
- **Grid-based rasterization**: Rasterize the sweep area onto a grid and check if stroke points fall in marked cells. Uses more memory and loses precision at low resolutions.

## Decision 2: Stroke Splitting Strategy

**Decision**: Identify contiguous runs of "surviving" points (points outside the sweep) and create a new `PencilStroke` for each run.

**Rationale**: This is the simplest correct approach. Each surviving run inherits the original paint and bezier distance. The bezier path is automatically recalculated from the new point list when `createDrawablePath()` is called (the existing `_requiresNewPathCreation` flag handles this).

**Alternatives considered**:

- **Segment-level splitting with interpolation**: Calculate exact intersection points where the sweep boundary crosses the stroke path and add interpolated points at the boundaries. More precise visual results at split boundaries but significantly more complex and may not be worth the visual difference given typical stroke densities.

## Decision 3: Undo Strategy

**Decision**: Use a sealed class (`PencilUndoAction`) with two variants: `UndoStrokeRestore` (for line-intersection erase) and `UndoDrawingSnapshot` (for radius erase). Store a full drawing snapshot before each radius erase gesture.

**Rationale**: Stroke splitting is not trivially reversible — new strokes are created and original strokes are discarded. Storing a snapshot is simple, correct, and has acceptable memory overhead for typical drawing sizes (hundreds of strokes at most).

**Alternatives considered**:

- **Command pattern with inverse operations**: Track each split/merge operation and its inverse. Far more complex with minimal benefit for the expected drawing sizes.

## Decision 4: Incremental vs. Batch Sweep Computation

**Decision**: Compute the sweep incrementally: each new eraser segment checks all current strokes and applies splits immediately.

**Rationale**: This provides real-time visual feedback (strokes disappear as the eraser moves over them) matching user expectations of a "real eraser." The full eraser path is not needed up front.

**Alternatives considered**:

- **Batch at pointer-up**: Compute all splits when the user lifts the pen. Simpler but provides no feedback during the gesture, which defeats the purpose of the radius indicator.

## Decision 5: Default Eraser Radius

**Decision**: Default radius of `10.0` logical pixels.

**Rationale**: Based on typical stylus stroke widths (2.0–4.0) in the example app, a 10px radius provides a comfortable eraser size that's easy to control. The radius is configurable, so this is just a sensible starting point.
