# Agile Roadmap: Earn Your Beers 🍻

This roadmap outlines the iterative development stages for the "Earn Your Beers" application. We prioritize getting a functional core into testing quickly, then layering on advanced gamification.

## Milestone 1: The Bare Essentials (Absolute MVP) 🚀
**Goal**: Log physical activity and drinks, and see a basic balance.
- **Flutter Framework Setup**: Basic project structure and navigation.
- **Manual Logging**: Simple forms for entering runs (KM) and drinks (Pints).
- **Core Calculation**: `Net Pints = (KM / 3) - Drinks`.
- **Local Persistence**: Save logs locally using Hive or Isar.
- **Dashboard**: A "Big Number" view showing current Pint balance.

## Milestone 2: The Core Gamification Loop 🔄
**Goal**: Standardize on the "Universal Unit" and introduce weekly cycles.
- **Universal Unit**: Activities converted to Pints in the UI.
- **Weekly Settlement**: Automatic Monday reset of the weekly tracker.
- **Running & Cycling Support**: Refined tracking for the two primary disciplines.
- **History View**: Review past logs and weekly performance.

## Milestone 3: The Brewery Bank 🏦
**Goal**: Progression, Strategic Bottling, and the "Tapped Out" mechanic.
- **12-Tier Master Brewer Journey**: Implementation of levels from **Yeast** to **Olympian**.
- **Bottling (Promotions)**: The 25-pint "Savings" requirement to level up.
- **The Cellar (Vault)**: A trophy room for your earned bottles.
- **Tapped Out (Demotions)**: Automatic safety net logic for excessive debt.
- **Additional Activities**: Add Walking, Gym, and Swimming support.

## Milestone 4: Premium Polish & Onboarding ✨
**Goal**: Visual excellence and optimized user entry.
- **Vibrant UI/UX**: Glassmorphism, animations, and high-end themes.
- **Placement Draft**: Onboarding questionnaire to seed initial league based on drinking/fitness habits.
- **Social & Competition**: Local "Cellar" comparisons (precursor to online leaderboards).
- **Novelty Bonus**: Multipliers for attempting new activity disciplines.
