# Milestone 1: Absolute MVP Breakdown 🚀

This document details the 7-commit execution strategy for the first milestone of the "Earn Your Beers" app.

## Commit 1: Project Scaffolding 🏗️
- **Action**: Run `flutter create .` (if not already done) or initialize the core structure.
- **Goal**: Clean `main.dart`, remove counters, and define the folder structure (`lib/core`, `lib/ui`, `lib/services`).
- **Dependencies**: Add `isar`, `isar_flutter_libs`, and `path_provider` to `pubspec.yaml`.

## Commit 2: Data Models (Identity Layer) 🆔
- **Action**: Create `lib/core/models/activity.dart` and `lib/core/models/drink.dart`.
- **Goal**: Define the schema for Isar.
  - `Activity`: id, date, type (Run), amount (KM).
  - `Drink`: id, date, amount (Pints).
- **Generation**: Trigger `build_runner` to create Isar schemas.

## Commit 3: Persistence Layer (Storage Engine) 💾
- **Action**: Create `lib/core/services/isar_service.dart`.
- **Goal**: Initialize the Isar database and provide methods for `saveActivity`, `saveDrink`, and `getLogs`.

## Commit 4: The Pint Engine (Logic) 🧮
- **Action**: Create `lib/core/logic/pint_calculator.dart`.
- **Goal**: A simple utility to calculate the current balance.
  - Formula: `(Total KM / 3.0) - Total Pints`.

## Commit 5: UI Foundation 🖼️
- **Action**: Build `lib/ui/dashboard_screen.dart`.
- **Goal**: A clean, empty state with a "Grand Balance" number at the top.

## Commit 6: Logging Forms 📝
- **Action**: Add "Add Run" and "Add Drink" buttons.
- **Goal**: Simple dialogs or bottom sheets to take numeric input and save to Isar via the service.

## Commit 7: Live Integration ⚡
- **Action**: Connect the Dashboard to the Isar stream.
- **Goal**: Ensure the balance updates instantly when a user logs a new drink or run.

---
**Next Milestone**: [Stage 2: The Core Loop](file:///Users/jamesbalenthiran/coding/earn_your_beers/docs/roadmap.md#stage-2-the-core-loop-)
