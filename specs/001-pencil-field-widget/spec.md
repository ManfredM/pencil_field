# Feature Specification: Pencil Field Widget

**Feature Branch**: `001-pencil-field-widget`  
**Created**: 2026-03-09  
**Status**: Draft  
**Input**: User description: "pencil_field widget specification"

## User Scenarios & Testing

### User Story 1 - Capture Freehand Input (Priority: P1)

A developer integrates PencilField into their Flutter application to capture freehand input from users. The user draws on the widget using a stylus or finger, and the input is captured as a collection of strokes stored in vector format. A callback notifies the application of each drawing change so the data can be persisted or processed.

**Why this priority**: Freehand input capture is the core purpose of the widget. Without it, no other functionality has value.

**Independent Test**: Can be fully tested by embedding a PencilField widget, drawing on it, and verifying strokes are captured and the change callback fires with each update.

**Acceptance Scenarios**:

1. **Given** a PencilField widget with a controller and callback, **When** the user starts drawing with a stylus, **Then** stroke data is captured and the onPencilDrawingChanged callback fires.
2. **Given** a PencilField widget with `pencilOnly` set to true, **When** the user attempts to draw with a finger (touch), **Then** the input is rejected and no strokes are recorded.
3. **Given** a PencilField widget with `pencilOnly` set to false, **When** the user draws with either a finger or stylus, **Then** input from both sources is accepted and captured.
4. **Given** a PencilField widget, **When** the user draws multiple separate strokes, **Then** each stroke is stored independently in the drawing and can be individually addressed.

---

### User Story 2 - Erase Strokes (Priority: P1)

The user switches to erase mode and draws an eraser path across existing strokes. Strokes that intersect with the eraser path are visually dimmed while erasing and removed when the user lifts the stylus. Erased strokes can be restored with an undo action.

**Why this priority**: Erasing is essential for any drawing input—users must be able to correct mistakes for the widget to be usable.

**Independent Test**: Can be tested by drawing strokes, switching to erase mode, crossing a stroke, and verifying it is removed. Then verifying undo restores it.

**Acceptance Scenarios**:

1. **Given** a drawing with multiple strokes and the controller in erase mode, **When** the user's eraser path crosses a stroke, **Then** the crossed stroke is visually dimmed (reduced opacity) immediately.
2. **Given** strokes marked for erasure, **When** the user lifts the stylus, **Then** the marked strokes are removed from the drawing.
3. **Given** strokes that were erased, **When** the user triggers undo, **Then** the last erased stroke is restored to the drawing.
4. **Given** a drawing with strokes, **When** the user triggers clear, **Then** all strokes are removed and the undo history is emptied.

---

### User Story 3 - Display Saved Drawings (Priority: P2)

A developer uses PencilDisplay to show a previously captured drawing in a read-only manner. The drawing can be scaled (e.g., for thumbnails or previews) because all data is stored in vector format.

**Why this priority**: Displaying captured drawings is the natural complement to capturing them—users need to see their previous input.

**Independent Test**: Can be tested by creating a PencilDrawing with strokes, passing it to PencilDisplay with a scale factor, and verifying the drawing renders correctly at the target size.

**Acceptance Scenarios**:

1. **Given** a PencilDrawing with strokes, **When** it is passed to PencilDisplay, **Then** the drawing is rendered as read-only without any input handling.
2. **Given** a PencilDrawing, **When** the scale method is called with a factor, **Then** all stroke points and paint widths are scaled proportionally.
3. **Given** a PencilDisplay with a decoration, **When** the widget renders, **Then** the decoration background is painted before the drawing strokes.

---

### User Story 4 - Persist and Restore Drawings (Priority: P2)

A developer serializes a PencilDrawing to JSON for storage and later deserializes it to restore the drawing. The serialization format is versioned so that future changes remain backward compatible.

**Why this priority**: Persistence enables practical use cases such as saving signatures, notes, or sketches for later retrieval.

**Independent Test**: Can be tested by creating a drawing, serializing to JSON, deserializing back, and verifying stroke data is identical.

**Acceptance Scenarios**:

1. **Given** a PencilDrawing with strokes, **When** toJson() is called, **Then** a versioned JSON map containing all stroke data (points, paint, bezier distance) is returned.
2. **Given** valid JSON data produced by toJson(), **When** PencilDrawing.fromJson() is called, **Then** the drawing is fully reconstructed with all original strokes and paint properties.
3. **Given** JSON data with an unsupported or missing version, **When** fromJson() is called, **Then** an empty drawing is returned without crashing.
4. **Given** JSON data with corrupt point data, **When** fromJson() is called, **Then** an empty stroke is returned and a debug warning is emitted without crashing.

---

### User Story 5 - Customize Background Decoration (Priority: P3)

A developer customizes the background of both PencilField and PencilDisplay using PencilDecoration. Predefined patterns (ruled lines, chequered grid, dots) and fully custom painters are supported. The pattern can be controlled by number of lines or fixed spacing.

**Why this priority**: Visual customization enhances the user experience and matches the widget to different use cases (e.g., signature fields vs. note-taking).

**Independent Test**: Can be tested by rendering a PencilField with each decoration type and verifying the correct visual pattern appears.

**Acceptance Scenarios**:

1. **Given** a PencilDecoration with type `ruled` and a specified number of lines, **When** the widget renders, **Then** horizontal lines are evenly distributed across the pattern area.
2. **Given** a PencilDecoration with type `chequered` and spacing, **When** the widget renders, **Then** both horizontal and vertical lines are drawn at the specified interval.
3. **Given** a PencilDecoration with type `dots`, **When** the widget renders, **Then** dots are drawn at grid intersections.
4. **Given** a PencilDecoration with type `custom` and a custom painter callback, **When** the widget renders, **Then** the custom painter receives the canvas, size, and pre-calculated coordinates.
5. **Given** a PencilDecoration with padding, **When** the widget renders, **Then** the pattern is inset from the widget edges by the specified padding.
6. **Given** a PencilDecoration with a paintProvider, **When** the widget renders, **Then** the provider is called for each line/dot enabling per-element paint customization.

---

### User Story 6 - Export Drawing as Image (Priority: P3)

A developer exports the current drawing as a raster image (PNG) for sharing, printing, or sending to a handwriting recognition service.

**Why this priority**: Image export enables integration with external systems and sharing functionality, extending the widget's utility beyond the Flutter app.

**Independent Test**: Can be tested by creating a drawing, exporting as PNG, and verifying the returned data is valid PNG bytes.

**Acceptance Scenarios**:

1. **Given** a PencilDrawing, **When** drawingAsImage is called with a background color, **Then** a PencilImage is returned with the correct size matching the drawing bounds.
2. **Given** a PencilImage, **When** toPNG() is called, **Then** valid PNG byte data is returned.
3. **Given** a PencilImage, **When** toImage() is called, **Then** a Flutter Image object is returned at the correct dimensions.
4. **Given** drawingAsImage called with a decoration, **When** the image is rendered, **Then** both the decoration pattern and drawing strokes appear in the output.

---

### Edge Cases

- What happens when a PencilField has no onPencilDrawingChanged callback set? → Input is silently ignored.
- What happens when a single point is drawn (tap without drag)? → A small dot is rendered at the tap location.
- How does the widget handle very rapid input? → Points closer than 0.1 units are filtered to avoid unnecessary density.
- What happens when padding exceeds the available widget size? → No decoration is painted and a debug message is emitted.
- What happens when the controller switches from erase to write mode? → Strokes currently marked for erasure are committed (removed).
- How does the widget behave on web vs. mobile platforms? → Web uses bezier distance 1; Android uses distance 3 for smoother rendering.
- What happens with undo when undo history is empty? → The undo call is silently ignored.
- What happens when setDrawing is called while in erase mode? → Mode resets to write and erase markers are cleared.

## Requirements

### Functional Requirements

- **FR-001**: The widget MUST capture freehand input from stylus devices across iOS, Android, and Web platforms.
- **FR-002**: The widget MUST support a stylus-only mode that rejects non-stylus input (e.g., finger touch).
- **FR-003**: The widget MUST provide write and erase interaction modes controlled through the controller.
- **FR-004**: In erase mode, the widget MUST detect intersections between the eraser path and existing strokes using line segment intersection.
- **FR-005**: Strokes intersected during erasing MUST be visually dimmed (reduced alpha) before final removal.
- **FR-006**: The widget MUST support undo of the last erased stroke, restoring it to the drawing.
- **FR-007**: The widget MUST support clearing all strokes and undo history.
- **FR-008**: The widget MUST provide a read-only display component (PencilDisplay) for rendering saved drawings.
- **FR-009**: Drawings MUST be scalable (all points and stroke widths) for preview and thumbnail generation.
- **FR-010**: All drawing data MUST be serializable to a versioned JSON format.
- **FR-011**: The widget MUST gracefully handle deserialization of unknown or corrupt JSON data by returning empty content without crashing.
- **FR-012**: The widget MUST support customizable background decorations: blank, ruled, chequered, dots, and custom painter.
- **FR-013**: Background decorations MUST support configuration through either a number of lines or a fixed spacing value.
- **FR-014**: The widget MUST support a custom paint provider callback for per-element decoration customization.
- **FR-015**: The widget MUST support exporting drawings as raster images (Image and PNG format).
- **FR-016**: Export MUST support rendering with either a background color or a full decoration.
- **FR-017**: The widget MUST use quadratic Bezier curve smoothing for drawn strokes.
- **FR-018**: The widget MUST filter input points that are too close together (minimum distance threshold) to avoid excessive point density.
- **FR-019**: Single-point strokes (taps) MUST be rendered as a visible dot.
- **FR-020**: The widget MUST notify the parent application of drawing changes via a callback.

### Key Entities

- **PencilDrawing**: A collection of strokes comprising a complete drawing. Supports serialization, scaling, and stroke management. Acts as the primary data model.
- **PencilStroke**: A sequence of points representing a single continuous stroke. Includes paint properties and supports intersection detection for erasing.
- **PencilPaint**: Defines the visual appearance (color, stroke width) of a stroke. Serializable to/from JSON.
- **PencilFieldController**: Manages the drawing state, interaction modes (write/erase), and operations (undo, clear). Bridges the widget and the drawing data.
- **PencilDecoration**: Configures the visual background of PencilField and PencilDisplay, supporting predefined patterns and custom painting.
- **PencilField**: The interactive input widget that captures freehand strokes.
- **PencilDisplay**: The read-only widget that renders an existing drawing.
- **PencilImage**: The output container for raster image export, supporting Image and PNG formats.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Users can draw freehand input that visually tracks the stylus with less than 16ms rendering latency (one frame at 60fps).
- **SC-002**: Users can erase unwanted strokes in a single gesture, with immediate visual feedback (dimming) during the erase action.
- **SC-003**: Users can undo the last erased stroke with a single action.
- **SC-004**: Drawings can be saved and restored from persisted data with 100% fidelity (all points, colors, and widths preserved).
- **SC-005**: Drawings can be scaled to any size while maintaining visual proportionality.
- **SC-006**: The widget supports stylus-only mode to prevent accidental touch input.
- **SC-007**: Background decorations render correctly for all supported types (blank, ruled, chequered, dots, custom).
- **SC-008**: The widget operates correctly on iOS, Android, and Web platforms.
- **SC-009**: Exported PNG images are valid and contain both the background and drawing content.
- **SC-010**: The widget handles corrupt or unsupported data gracefully without crashing.

## Assumptions

- The widget targets Flutter applications running on iOS, Android, and Web. Desktop platforms (macOS, Windows, Linux) are not currently in scope per deployment restrictions.
- Performance expectations follow standard Flutter widget guidelines: 60fps rendering on mobile, best-effort on web.
- The JSON serialization format uses version 1; future versions will add migration support.
- The minimum point distance threshold (0.1) provides a good balance between accuracy and performance across all target platforms.
- Bezier distance varies by platform (1 for iOS/Web, 3 for Android) as a platform-specific optimization.
- The eraser intersects whole strokes (removes the entire stroke if any segment is crossed), not individual segments within a stroke.
- Image export dimensions are determined by the drawing's bounding box, not the widget's display size.
