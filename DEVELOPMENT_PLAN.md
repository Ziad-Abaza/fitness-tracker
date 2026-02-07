# Development Plan - Fitness Tracker Evolution

This document outlines the step-by-step roadmap for enhancing the Fitness Tracker's visual identity, logic accuracy, and user empowerment.

## Design Principles
- **UX Simplicity**: Reduce friction in logging and navigation.
- **Visual Intuition**: Immediate clarity through images and color coding.
- **Zero Feature Creep**: Focus strictly on the defined roadmap.

---

## Phase 1: Visual Identity & Arabic Foundation
*Focus: Enhancing the Exercise model and adding visual previews.*

### 1.1 Exercise Model Extension
- **Task**: Update `Exercise` model in `lib/models/exercise.dart`.
- **Changes**:
    - Add `String? name_ar`.
    - Add `List<String>? instructions_ar`.
    - Update `fromJson`/`toJson` to include these fields.
    - Ensure `gifPath` correctly points to `assets/datasets/gifs/$id.gif`.

### 1.2 Data Source Update (Arabic)
- **Task**: Sample localization for core exercises.
- **Changes**:
    - Manually update `assets/datasets/exercises.json` with `name_ar` and `instructions_ar` for a subset of exercises (e.g., Bench Press, Squat).

### 1.3 Thumbnail Previews in UI
- **Task**: Infuse the UI with exercise visuals.
- **Screens**:
    - **Routines Screen**: Show a small horizontal scroll or overlap of exercise thumbnails included in each routine.
    - **Library Screen / Exercise Picker**: Add a thumbnail leading widget to each list item.
    - **Active Workout Screen**: Show the GIF of the current exercise at the top or in the exercise card.

### 1.4 Category Chips (Smart Filtering)
- **Task**: Add horizontal scrolling chips for body parts (Chest, Back, Legs, etc.) in the `LibraryScreen`.
- **Logic**: Use `ExerciseService.filterExercises` to update the list on chip selection.

---

## Phase 2: Smart Scheduler & Real Data
*Focus: Organizing routines by time and replacing placeholders with logic.*

### 2.1 Routine Model & DB Update (Scheduler Logic)
- **Task**: Extend `Routine` to support scheduling.
- **Changes**:
    - Update `Routine` model to include `List<int> scheduledDays` (1=Mon, 7=Sun).
    - Update `DatabaseHelper` to add `scheduledDays` column (TEXT) to `routines` table.
    - Handle database version migration to version 2.

### 2.2 Routine Builder - Schedule Selection
- **Task**: Add a "Schedule" section in `RoutineBuilderScreen`.
- **UI**: A row of 7 circular day toggles (M, T, W, T, F, S, S).

### 2.3 Home Screen: "Today's Workout"
- **Task**: Dynamic Home Screen based on current day.
- **Logic**: 
    - Fetch routines where `scheduledDays` contains `DateTime.now().weekday`.
    - If found, display as a prominent card on the Dashboard.
    - If no workout is scheduled, show "Rest Day" or "Quick Start" suggestion.

### 2.4 Real-Data Volume Chart
- **Task**: Replace static bar chart with SQL-driven volume logic.
- **Logic**:
    - Query `sets` joined with `sessions` for the last 7 sessions.
    - Calculate Volume: `SUM(weight * reps)` per session.
    - Update `WorkoutProvider` to expose this real data stream.

---

## Phase 3: Active Workout UX Redesign
*Focus: Optimizing the logging experience for speed and clarity.*

### 3.1 Standardization (3-Set Default)
- **Task**: Default exercise initialization.
- **Logic**: When adding an exercise to a routine or session, automatically pre-fill 3 sets with default values (or values from `getLastPerformance`).

### 3.2 Input Clarity & Accessibility
- **Task**: Redesign the set log row in `ActiveWorkoutScreen`.
- **UI**:
    - Explicit labels: "WEIGHT (KG)" and "REPS".
    - Wrap numeric fields in large, bordered containers with `fontFamily: 'Orbitron'`.
    - Increase hit area for number tapping.

### 3.3 Set Status Visualization
- **Task**: Clear distinction between logged and unlogged sets.
- **Visuals**:
    - **Pending**: Subtle border, semi-opaque background.
    - **Completed**: Filled primary color background or checkmark icon, full opacity.

---

## Phase 4: User Empowerment
*Focus: Allowing users to expand the library locally.*

### 4.1 Custom Exercise Infrastructure
- **Task**: Persistent storage for custom exercises.
- **Changes**:
    - Create `user_exercises` table in SQLite with same schema as JSON exercises.
    - Update `ExerciseService` to merge results from JSON and SQLite.

### 4.2 Exercise Creator Screen
- **Task**: Dedicated UI for manual entry.
- **Fields**: Name, Category (Body Part), Equipment, Primary Muscles, Name (Arabic).

### 4.3 Image Upload Support
- **Task**: Local image association.
- **Implementation**:
    - Add `image_picker` to `pubspec.yaml`.
    - Use `image_picker` to select from gallery.
    - Save local file path to `user_exercises` table.
    - Display local image if `images` list contains a local file path.
