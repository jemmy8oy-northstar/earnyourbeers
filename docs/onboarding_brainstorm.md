# Brainstorming: Simple Onboarding & Difficulty Scaling 📋

This document outlines the strategy for seeding new users into the correct league and maintaining long-term challenge through dynamic difficulty.

## 🧠 Questionnaire Design (Volume-Based)

Instead of vague buttons, we use interactive sliders to capture the user's current fitness baseline.

### 1. The Volume Check
**Question**: "On average, how much do you do per week?"
- **Run**: `0 - 100+ km`
- **Cycle**: `0 - 300+ km`
- **Swim**: `0 - 500+ lengths`

**Initial Seeding Logic**:
We project their current volume into a "Standard Week" (Tier 0 difficulty).

| Weekly Volume (Run) | Est. Points (Standard) | Seeded Tier | Division |
| :--- | :--- | :--- | :--- |
| < 10 km | < 5 pts | **Tier 0 (Noob)** | Apprenticeship |
| 10 - 30 km | 5 - 15 pts | **Tier 5 (Regular)** | Practice |
| 30 - 60 km | 15 - 30 pts | **Tier 10 (Specialist)** | Mastery |
| 60+ km | 30+ pts | **Tier 15 (Master)** | Legacy |

### 2. The Primary Discipline
**Question**: "Which is your primary focus?"
- **Running 🏃** (Multiplier: 1.0)
- **Cycling 🚴** (Multiplier: 0.8 - adjusted for transit convenience)
- **Swimming 🏊** (Multiplier: 1.1 - adjusted for technical friction)

### 3. The Vice Selection
**Question**: "What are we working for today?"
- Select first vice emoji (e.g., 🍕, 🎮, 🍩).

---

## 📈 Granular Tier Scaling (The "Standard" Shift)

To ensure every rank feels harder than the last, the reward multiplier now decreases by **0.015 (1.5%)** for every single tier gain. This creates a smooth gradient from **1.0x (Noob)** to **0.7x (Legend)**.

### Difficulty Formula
`Multiplier = 1.0 - (CurrentLevel * 0.015)`

### Level-by-Level Breakdown (Sample)

| Level | Rank | Multiplier | Run (pts/km) |
| :--- | :--- | :--- | :--- |
| **0** | Noob | **1.000x** | 0.500 |
| **1** | Novice | **0.985x** | 0.492 |
| **2** | Weekender | **0.970x** | 0.485 |
| **5** | Regular | **0.925x** | 0.462 |
| **10** | Specialist | **0.850x** | 0.425 |
| **15** | Master | **0.775x** | 0.387 |
| **20** | Legend | **0.700x** | 0.350 |

---

## 🧪 Budget Stress Tests (The Extremes)

To ensure the math holds, we look at the two absolute boundaries of human performance and indulgence.

### Scenario A: The Ultra-Athlete (Legend T20)
*   **Activity**: 500 km Running / Week
*   **Vices**: 0
*   **Multiplier**: 0.70x (Legend Standard)
*   **Math**: `(500 * 0.5 * 0.7) - 0 = +175.0 points`
*   **Outcome**: Clears the "Double Promotion" (+50) threshold 3.5x over. This user effectively "breaks" the rank system and reaches god-tier status instantly.

### Scenario B: The Vice-Heavy Beginner (Noob T0)
*   **Activity**: 5 km Running / Week
*   **Vices**: 50 (e.g., 50 beers/pizzas)
*   **Multiplier**: 1.00x (Standard)
*   **Math**: `(5 * 0.5 * 1.0) - 50 = -47.5 points`
*   **Outcome**: Triggers an immediate demotion (-25 floor) and carries over a heavy "Vice Debt."

### Conclusion
These extremes prove the system is robust:
1.  **Outliers don't break the logic**: Professional athletes get the recognition they deserve.
2.  **Debt exists**: Users cannot "run off" a 50-vice week with a token 5k run. They must earn it back over time.

---

## 🏗️ Seeding Logic & Mapping (Volume Based)

Because difficulty is now granular, seeding uses a "Zero-Sum" projection. We place the user in the tier where their current volume would earn them a **Net Neutral (+0)** week after accounting for their vice habits.

**The "Standard Athlete" Profile (Seeding Tiers):**
Assuming a user earns ~25 points (one promotion) at **Tier 0 difficulty** (Standard):

| Weekly Volume (Run) | Logic | Starting Rank |
| :--- | :--- | :--- |
| **0 - 10 km** | Maintenance / Beginner volume. | **T0: Noob** |
| **20 - 30 km** | Consistent recreational runner. | **T5: Regular** |
| **40 - 50 km** | Training for an event / club level. | **T10: Specialist** |
| **60 - 80 km** | Semi-pro / Daily high-volume worker. | **T15: Master** |
| **100+ km** | Elite / Professional volume. | **T20: Legend** |

### Why scale difficulty?
1. **Prevents Point Inflation**: High-volume athletes would otherwise "break" the economy.
2. **Reflects Mastery**: As fitness improves, the "cost of entry" for a vice should naturally rise.
3. **Endgame Challenge**: Reaching "Legend" (T20) requires genuine dedication to the lifestyle.

---

## ✨ UI/UX Flow

1. **The Pulse Analysis**: After the sliders, show the "Scanner" animation.
2. **The Rank Reveal**: 
   - "Analysis complete."
   - "Based on your current volume of **50km/week**..."
   - "You are starting in the **Mastery Division (Tier 10)**!"
3. **The Skip-The-Grind Value**: Explicitly tell the user: *"You've skipped the first 10 ranks. Ready to maintain your status?"*
