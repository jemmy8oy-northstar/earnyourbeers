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

## 📈 The "Progressive Standard" (Full 20-Tier Ratios)

To ensure every rank feels harder than the last, the reward multiplier decreases by **0.015 (1.5%)** for every single tier gain.

### Multiplier Table

| Tier | Rank Name | Multiplier | Run (pts/km) | Cycle (pts/km) | Swim (pts/30L) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Noob | **1.000x** | 0.500 | 0.066 | 1.000 |
| **1** | Novice | **0.985x** | 0.492 | 0.065 | 0.985 |
| **2** | Weekender | **0.970x** | 0.485 | 0.064 | 0.970 |
| **3** | Rookie | **0.955x** | 0.477 | 0.063 | 0.955 |
| **4** | Apprentice | **0.940x** | 0.470 | 0.062 | 0.940 |
| **5** | Regular | **0.925x** | 0.462 | 0.061 | 0.925 |
| **6** | Grinder | **0.910x** | 0.455 | 0.060 | 0.910 |
| **7** | Athlete | **0.895x** | 0.447 | 0.059 | 0.895 |
| **8** | Competitor | **0.880x** | 0.440 | 0.058 | 0.880 |
| **9** | Professional | **0.865x** | 0.432 | 0.057 | 0.865 |
| **10** | Specialist | **0.850x** | 0.425 | 0.056 | 0.850 |
| **11** | Relentless | **0.835x** | 0.417 | 0.055 | 0.835 |
| **12** | Veteran | **0.820x** | 0.410 | 0.054 | 0.820 |
| **13** | Expert | **0.805x** | 0.402 | 0.053 | 0.805 |
| **14** | Champion | **0.790x** | 0.395 | 0.052 | 0.790 |
| **15** | Master | **0.775x** | 0.387 | 0.051 | 0.775 |
| **16** | Grandmaster | **0.760x** | 0.380 | 0.050 | 0.760 |
| **17** | Elite | **0.745x** | 0.372 | 0.049 | 0.745 |
| **18** | Titan | **0.730x** | 0.365 | 0.048 | 0.730 |
| **19** | Titan+ | **0.715x** | 0.357 | 0.047 | 0.715 |
| **20** | Legend | **0.700x** | 0.350 | 0.046 | 0.700 |

> [!NOTE]
> The **Cycle** value is based on the 15km = 1pt rule. The **Swim** value is based on 30 lengths = 1pt. These are then scaled by the multiplier.

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
