# Tasks: Radius-Based Sweep Eraser

**Input**: Design documents from `/specs/002-radius-eraser/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)

---

## Phase 1: Setup

**Purpose**: Extend the PencilMode enum and undo architecture — a prerequisite for all subsequent work.

- [x] T001 Add `radiusErase` value to the `PencilMode` enum in `lib/src/controller.dart`
- [x] T002 Create sealed class `PencilUndoAction` with `UndoStrokeRestore` and `UndoDrawingSnapshot` variants in `lib/src/controller.dart`
- [x] T003 Refactor `_undoStrokes` to `_undoActions` (type `List<PencilUndoAction>`) in `lib/src/controller.dart`, update existing `undo()` and `clear()` to use `UndoStrokeRestore` entries so existing line-intersection erase behavior is preserved

**Checkpoint**: Existing tests must still pass (`flutter test`). No behavioral change yet.

---

## Phase 2: Foundational — Geometry Primitives

**Purpose**: Implement the core geometry methods on `PencilStroke` that all user stories depend on.

**⚠️ CRITICAL**: User story tasks cannot begin until these geometry methods exist.

- [x] T004 [P] Implement static method `pointToSegmentDistance(Point p, Point segStart, Point segEnd)` on `PencilStroke` in `lib/src/stroke.dart` — computes shortest distance from a point to a line segment using vector projection clamped to [0,1]
- [x] T005 [P] Implement method `splitByRadius({required List<Point> eraserPoints, required double radius})` on `PencilStroke` in `lib/src/stroke.dart` — iterates over stroke points, checks each against all eraser segments using `pointToSegmentDistance`, groups surviving points into contiguous runs, returns `List<PencilStroke>` with preserved paint and bezier distance
- [x] T006 [P] Add unit tests for `pointToSegmentDistance` in `test/stroke_test.dart` — test cases: point on segment (distance 0), point perpendicular to midpoint, point beyond endpoint, degenerate segment (start == end)
- [x] T007 [P] Add unit tests for `splitByRadius` in `test/stroke_test.dart` — test cases: eraser misses stroke (returns original), eraser covers entire stroke (returns empty), eraser crosses middle (returns two sub-strokes), eraser covers one end (returns one shorter stroke), single-point stroke within/outside radius, verify split strokes preserve paint and bezier distance

**Checkpoint**: `flutter test test/stroke_test.dart` — all new geometry tests pass. Existing stroke tests still pass.

---

## Phase 3: User Story 1 — Core Sweep Erasing (Priority: P1) 🎯 MVP

**Goal**: Users can erase stroke segments within a configurable radius sweep along the eraser path.

**Independent Test**: Draw strokes, switch to `radiusErase`, sweep across part of one stroke, verify only the portion within the sweep is removed and remaining parts become independent strokes.

### Implementation for User Story 1

- [x] T008 [US1] Add `_eraserRadius` field (default `10.0`) and `_preRadiusEraseSnapshot` field to `PencilFieldController` in `lib/src/controller.dart`
- [x] T009 [US1] Extend `setMode()` to accept optional `eraserRadius` parameter; handle `radiusErase` mode: store eraser radius, initialize eraser state, take drawing snapshot, add debug assertion for invalid radius (≤0) in `lib/src/controller.dart`
- [x] T010 [US1] Add `radiusErase` case to `startPath()` in `lib/src/controller.dart` — create eraser stroke and snapshot the current drawing into `_preRadiusEraseSnapshot`
- [x] T011 [US1] Add `radiusErase` case to `addPointToPath()` in `lib/src/controller.dart` — append point to eraser stroke, then for each stroke in `_drawing`: call `splitByRadius` with full eraser path and radius, replace the stroke with split results
- [x] T012 [US1] Add `radiusErase` case to `endPath()` in `lib/src/controller.dart` — push `UndoDrawingSnapshot(_preRadiusEraseSnapshot)` onto `_undoActions`, clear eraser state
- [x] T013 [US1] Add unit tests for radius erase controller logic in `test/controller_test.dart` — test cases: enter radiusErase mode, sweep across a stroke (verify split/removal), sweep that misses all strokes (no changes), erase single-point stroke within radius
- [x] T014 [US1] Add widget test for radius erasing in `test/field_test.dart` — draw strokes via gesture, set controller to `radiusErase`, simulate erase gesture across part of a stroke, verify stroke count changes appropriately

**Checkpoint**: `flutter test` — radius erase core works. Drawing strokes, erasing with radius, and verifying splits all pass.

---

## Phase 4: User Story 2 — Visual Feedback (Priority: P1)

**Goal**: Users see a radius indicator at the eraser position and dimmed strokes within the sweep during the erase gesture.

**Independent Test**: Enter radiusErase mode, move the eraser slowly, verify the radius circle appears and affected strokes are dimmed.

### Implementation for User Story 2

- [x] T015 [US2] Add radius indicator rendering to `_PencilFieldPainter.paint()` in `lib/src/field.dart` — when mode is `radiusErase` and eraser has points, draw a semi-transparent circle at the last eraser point with the configured radius
- [x] T016 [US2] Expose `eraserRadius` getter on `PencilFieldController` in `lib/src/controller.dart` so the painter can access the radius value
- [x] T017 [US2] Handle dimming of affected strokes in `PencilFieldController.draw()` for `radiusErase` mode in `lib/src/controller.dart` — strokes that differ from the pre-erase snapshot are rendered with reduced alpha (similar to existing erase dimming logic)

**Checkpoint**: Visual feedback renders correctly during radius erase gestures. Existing drawing and line-intersection erase rendering is unchanged.

---

## Phase 5: User Story 3 — Configurable Radius (Priority: P2)

**Goal**: Developers can configure the eraser radius; the default is sensible.

**Independent Test**: Set different radius values and verify the sweep area changes accordingly.

### Implementation for User Story 3

- [x] T018 [US3] Verify `setMode(PencilMode.radiusErase, eraserRadius: X)` works with custom radius values — add test in `test/controller_test.dart` confirming radius is stored and applied
- [x] T019 [US3] Add test for default radius (no explicit value) and invalid radius (≤0, assert fires) in `test/controller_test.dart`

**Checkpoint**: Radius configuration and validation tests pass.

---

## Phase 6: User Story 4 — Undo Support (Priority: P2)

**Goal**: Users can undo the last radius erase gesture, restoring all original strokes from that gesture as a single undo step.

**Independent Test**: Erase part of a stroke, call undo, verify the original stroke is restored.

### Implementation for User Story 4

- [x] T020 [US4] Extend `undo()` in `lib/src/controller.dart` to handle `UndoDrawingSnapshot` entries — pop the snapshot and replace `_drawing` entirely
- [x] T021 [US4] Add unit tests for undo after radius erase in `test/controller_test.dart` — test cases: undo restores original drawing, multiple gestures + multiple undos (each gesture undone independently), undo when history is empty (silently ignored)
- [x] T022 [US4] Add widget test for undo after radius erase in `test/field_test.dart` — draw, radius erase, undo via controller, verify original stroke count is restored

**Checkpoint**: Undo works for radius erase. Existing undo behavior for line-intersection erase is unchanged.

---

## Phase 7: User Story 5 — Coexistence with Line-Intersection Eraser (Priority: P3)

**Goal**: Both eraser modes coexist; the existing eraser is fully preserved. Switching between modes cleans up pending state.

**Independent Test**: Switch between erase and radiusErase modes and verify each uses its own logic.

### Implementation for User Story 5

- [x] T023 [US5] Extend `setMode()` in `lib/src/controller.dart` to properly clean up pending state when switching between `erase` and `radiusErase` (commit any pending erase marks or sweep state)
- [x] T024 [US5] Add test for switching between `erase` and `radiusErase` modes in `test/controller_test.dart` — verify each mode uses its own logic and pending state is cleaned up on switch

**Checkpoint**: All eraser modes work independently and switching between them is clean.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and cleanup.

- [x] T025 Run full test suite (`flutter test`) and verify zero regressions across all existing tests
- [x] T026 Run `flutter analyze` and fix any warnings or lint issues in modified files
- [x] T027 Add dartdoc comments to all new public API members (`radiusErase`, `eraserRadius`, `pointToSegmentDistance`)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 (enum + undo types must exist)
- **Phase 3 (US1 Core Erasing)**: Depends on Phase 2 (geometry methods must exist)
- **Phase 4 (US2 Visual Feedback)**: Depends on Phase 3 (controller must handle radiusErase)
- **Phase 5 (US3 Configurable Radius)**: Depends on Phase 3 (core erase mode must exist)
- **Phase 6 (US4 Undo)**: Depends on Phase 3 (erase must produce undo entries)
- **Phase 7 (US5 Coexistence)**: Depends on Phase 3 (both modes must exist)
- **Phase 8 (Polish)**: Depends on all previous phases

### Parallel Opportunities

```text
After Phase 2 (Foundational) completes:
  ├── Phase 3 (US1) must be first (core dependency)
  │
  After Phase 3 completes:
  ├── Phase 4 (US2 Visual Feedback)     ─┐
  ├── Phase 5 (US3 Configurable Radius) ─┼── can run in parallel
  ├── Phase 6 (US4 Undo)                ─┤
  └── Phase 7 (US5 Coexistence)         ─┘
```

Within phases:

- T004 + T005 can run in parallel (different methods)
- T006 + T007 can run in parallel (different test groups)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational geometry (T004–T007)
3. Complete Phase 3: Core sweep erasing (T008–T014)
4. **STOP and VALIDATE**: `flutter test` — all tests pass, radius erase works
5. This is a usable MVP — erasing works, just without visual indicator

### Incremental Delivery

1. Setup + Foundational → geometry ready
2. Add US1 → core erasing works → **MVP!**
3. Add US2 → visual feedback → polished experience
4. Add US3 + US4 → configurable + undoable → full feature
5. Add US5 → backward compatibility validated → release ready

---

## Notes

- Total tasks: **27**
- Tasks per phase: Setup (3), Foundational (4), US1 (7), US2 (3), US3 (2), US4 (3), US5 (2), Polish (3)
- Primary file changes: `controller.dart` (most changes), `stroke.dart` (geometry), `field.dart` (visual)
- Tests throughout: `stroke_test.dart`, `controller_test.dart`, `field_test.dart`
- All existing tests must pass at every checkpoint
