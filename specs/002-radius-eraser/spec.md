# Feature Specification: Radius-Based Sweep Eraser

**Feature Branch**: `002-radius-eraser`  
**Created**: 2026-03-09  
**Status**: Draft  
**Input**: User description: "The current eraser is based on line intersection. Lines that intersect with the eraser are deleted. I want the eraser to have a radius and based on the path we create a sweep outline. Everything within this outline gets erased (like a real eraser does)."

## User Scenarios & Testing

### User Story 1 - Erase Strokes Within a Radius Sweep (Priority: P1)

The user selects the radius-based eraser mode and draws across the canvas. As the eraser moves, a visible sweep area (defined by the eraser radius) follows the path. Any stroke point that falls within this sweep area is considered erased. The eraser behaves like a physical eraser—only the parts of the drawing that are directly "under" the eraser are removed, not entire strokes.

**Why this priority**: This is the core feature. The sweep-based erasing is the fundamental user interaction that defines this eraser type.

**Independent Test**: Can be tested by drawing several strokes, switching to the radius eraser, sweeping across part of one stroke, and verifying only the portions within the sweep area are erased.

**Acceptance Scenarios**:

1. **Given** a drawing with strokes and the controller in radius-erase mode with a radius of R, **When** the user draws an eraser path, **Then** a sweep area is computed as the union of circles (radius R) centered along each eraser path point.
2. **Given** a sweep area, **When** the eraser path crosses through the middle of a stroke, **Then** only the stroke points within the sweep area are removed, leaving the remaining parts of the stroke intact as separate strokes.
3. **Given** a sweep area that entirely covers a short stroke, **When** the eraser is lifted, **Then** the entire stroke is removed.
4. **Given** a sweep area that does not touch any stroke, **When** the eraser is lifted, **Then** no strokes are modified.

---

### User Story 2 - Visual Feedback During Radius Erasing (Priority: P1)

While the user is erasing, the actual sweep body is rendered on the canvas as a semi-transparent (50% opacity) filled polygon. This polygon represents the exact area being erased—the union of capsule shapes along the eraser path—so the user can clearly see what will be removed. This replaces a simple radius indicator circle with a true representation of the eraser's footprint.

**Why this priority**: Without visual feedback, the radius eraser is unusable—the user cannot predict or control what will be erased. Showing the actual sweep body (rather than just a circle at the tip) gives the user precise understanding of the erase area.

**Independent Test**: Can be tested by entering radius-erase mode, moving the eraser slowly, and verifying that a filled semi-transparent polygon covering the full sweep path is displayed in real time.

**Acceptance Scenarios**:

1. **Given** the controller in radius-erase mode, **When** the eraser moves, **Then** the actual sweep body is rendered as a filled semi-transparent (50% opacity) polygon showing the exact area being erased.
2. **Given** the eraser has traced a path with multiple points, **When** the polygon is rendered, **Then** it represents the union of capsule shapes (rectangles with semicircular end caps) connecting consecutive eraser path points at the configured radius.
3. **Given** the eraser has only a single point (tap without drag), **When** the polygon is rendered, **Then** a filled semi-transparent circle of the configured radius is displayed at that point.

---

### User Story 3 - Configure Eraser Radius (Priority: P2)

The developer can configure the radius of the eraser when setting the mode. Different use cases require different eraser sizes—a fine eraser for detailed corrections and a large eraser for clearing bigger areas.

**Why this priority**: Configurability is important for practical use but the eraser works with a sensible default. This builds on the core functionality.

**Independent Test**: Can be tested by setting different radius values and verifying the sweep area size changes accordingly.

**Acceptance Scenarios**:

1. **Given** a radius-erase mode is activated with a specific radius value, **When** the eraser is used, **Then** the sweep area corresponds to that radius.
2. **Given** no explicit radius is provided, **When** radius-erase mode is activated, **Then** a sensible default radius is used.
3. **Given** an invalid radius (zero or negative), **When** the developer attempts to set it, **Then** a debug assertion is triggered.

---

### User Story 4 - Undo Radius Erasing (Priority: P2)

After an erase action, the user can undo the last erase operation. Undo restores all stroke modifications from the most recent erase gesture (pointer down → pointer up) as a single undo step.

**Why this priority**: Undo is essential for a good erasing experience, but it depends on the core erase feature being implemented first.

**Independent Test**: Can be tested by erasing part of a stroke, calling undo, and verifying the original stroke is restored.

**Acceptance Scenarios**:

1. **Given** strokes were partially erased by a radius erase gesture, **When** the user triggers undo, **Then** all modifications from that gesture are reverted and the original strokes are restored.
2. **Given** multiple consecutive erase gestures, **When** the user triggers undo multiple times, **Then** each gesture is undone in reverse order.
3. **Given** no erase actions have been performed, **When** the user triggers undo, **Then** the action is silently ignored.

---

### User Story 5 - Coexistence with Existing Line-Intersection Eraser (Priority: P3)

Both the existing line-intersection eraser and the new radius-based eraser are available as separate modes. The developer chooses which eraser mode to use via the controller. The existing eraser behavior is fully preserved.

**Why this priority**: Backward compatibility ensures existing users are not affected. Both eraser types have valid use cases.

**Independent Test**: Can be tested by switching between the two erase modes and verifying each behaves independently with its own logic.

**Acceptance Scenarios**:

1. **Given** the existing erase mode is selected, **When** the user erases, **Then** the eraser uses line-intersection logic (existing behavior, unchanged).
2. **Given** the radius-erase mode is selected, **When** the user erases, **Then** the eraser uses the sweep-area logic.
3. **Given** a switch from one erase mode to another, **When** the mode changes, **Then** any pending erase state from the previous mode is properly cleaned up.

---

### Edge Cases

- What happens when the eraser radius is very large and covers many strokes? → All covered strokes are erased; performance should remain acceptable for typical drawing sizes.
- What happens when a stroke is split into three or more segments by the eraser? → Each remaining segment becomes an independent stroke.
- What happens when erasing removes all points from a stroke? → The stroke is completely removed from the drawing.
- What happens when a single-point stroke (dot) falls within the sweep? → The dot is erased.
- What happens when the eraser path has only a single point (tap without drag)? → A circle of the given radius is used as the erase area.
- What happens when the eraser radius is very small (e.g., 1 pixel)? → The eraser effectively targets only points very close to the path, similar to a precision eraser.
- How does stroke splitting preserve paint properties? → Split strokes inherit the paint (color, width) and bezier distance from the original stroke.

## Requirements

### Functional Requirements

- **FR-001**: The system MUST support a radius-based erase mode that erases stroke content within a configurable circular sweep area along the eraser path.
- **FR-002**: The sweep area MUST be computed as the union of circles of the configured radius, centered at each point of the eraser path (forming a capsule/stadium shape between consecutive points).
- **FR-003**: Any stroke point that falls within the sweep area MUST be considered for erasure.
- **FR-004**: When a stroke is partially within the sweep area, the system MUST split the stroke into the remaining segments, each becoming an independent stroke.
- **FR-005**: Split strokes MUST preserve the original stroke's paint properties (color, stroke width) and bezier distance.
- **FR-006**: The system MUST provide real-time visual feedback by rendering the actual sweep body as a filled semi-transparent (50% opacity) polygon on the canvas, representing the exact area being erased.
- **FR-007**: The sweep body polygon MUST be computed as the outline of the union of capsule shapes (rectangles capped with semicircles) along the eraser path at the configured radius.
- **FR-008**: Erasure MUST be committed (finalized) when the user lifts the stylus (pointer up).
- **FR-009**: The system MUST support undo of a complete erase gesture, restoring all original strokes from that gesture as a single undo step.
- **FR-010**: The eraser radius MUST be configurable by the developer with a sensible default value.
- **FR-011**: The existing line-intersection eraser MUST remain available and its behavior MUST NOT be altered.
- **FR-012**: Completely erased strokes (all points within the sweep) MUST be fully removed from the drawing.
- **FR-013**: The radius eraser MUST handle single-point strokes (dots) by checking if the point falls within the sweep area.

### Key Entities

- **Sweep Area**: The geometric region defined by the union of circles along the eraser path. Forms capsule/stadium shapes between consecutive eraser points. This is the "footprint" of the eraser.
- **Sweep Body Polygon**: The visual outline of the sweep area, rendered as a filled semi-transparent polygon on the canvas during the erase gesture. Computed by offsetting the eraser path by the radius on both sides and connecting endpoint semicircles.
- **Eraser Radius**: A configurable distance value that defines the size of the sweep area around the eraser path.
- **Stroke Split**: The operation of dividing a partially-erased stroke into separate independent strokes, each containing a contiguous run of points outside the sweep area.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Users can erase portions of strokes with precision determined by the configurable radius, without removing entire strokes unintentionally.
- **SC-002**: Users see the exact sweep area rendered as a filled semi-transparent polygon in real time during the erase gesture, with no perceptible delay.
- **SC-003**: Users can undo any erase gesture completely with a single undo action, restoring the original strokes.
- **SC-004**: Existing line-intersection eraser behavior is fully preserved with no regressions.
- **SC-005**: Stroke splitting produces visually seamless results—the remaining segments look the same as the original stroke minus the erased portion.
- **SC-006**: The eraser operates at interactive frame rates (≤16ms per frame) for drawings with up to 100 strokes.

## Assumptions

- The sweep area is modeled geometrically as capsule shapes (rectangle capped with semicircles) between consecutive eraser points. This is equivalent to checking if each stroke point is within the eraser radius of any point on the eraser path.
- A simpler but more performant approach—checking the distance from each stroke point to each eraser path segment—is acceptable and produces equivalent results to a true swept outline.
- The eraser radius is expressed in the same coordinate units as the drawing points (logical pixels).
- When a stroke is split, the bezier path is recalculated from the remaining points in each segment, so the visual smoothing adapts to the new endpoints.
- Undo granularity is per-gesture (pointer down to pointer up), not per-point.
- The PencilMode enum will be extended with a new value for the radius eraser, keeping the existing `erase` value for backward compatibility.
