# Brainstorming: Simple Onboarding & Difficulty Scaling 📋

This document outlines the strategy for seeding new users into the correct league and maintaining long-term challenge through dynamic difficulty.

## 🧠 Questionnaire Design (Adaptive Logic)

We use a 4-step interactive flow to build the user's "Fitness Economy."

### 1. The Core Engine (Sport Choice)
**Question**: "What's your primary discipline?"
- **Running 🏃** (Unit: KM)
- **Cycling 🚴** (Unit: KM)
- **Swimming 🏊** (Unit: Lengths)
*Purpose*: Tailors the units and ranges for the Volume slider.

### 2. The Volume Check
**Question**: "On average, how much do you do per week?"
- **Run**: `0 - 100+ km`
- **Cycle**: `0 - 300+ km`
- **Swim**: `0 - 1000+ lengths`
*Seeding Logic*: Finds the Tier where this volume = **25 Points** (Our Par Achievement).

### 3. The Rebrand (Vice Selection) 🎨
**Question**: "What are we working for today?"
- Choose emoji and custom name (e.g., "Craft Beer", "Pizza").
*Purpose*: Personalizes the experience before the "Sustainability Check."

### 4. The Vice Audit ⚖️
**Question**: "Be honest: how many [Selected Vice] do you typically have a week?"
*Range*: `0 - 40+`
*Sustainability Logic*: 
- If `(Volume Points) - (Vice Count) < -15`, the user is in a "Death Spiral."
- **Nudge**: We recommend starting **5 levels lower** than their seeded tier to give them "Growth Room."

---

## 📈 The "Extreme 100:1" Scaling (Exponential)

To capture the vast difference between a beginner's 5km and an elite's 500km, the reward multiplier now decays exponentially from **10.0x (Noob)** to **0.1x (Legend)** relative to the standard 0.5 pts/km base.

### Multiplier Table (100:1 Range)

| Tier | Rank Name | Multiplier | Run (25pts @) | Cycle (25pts @) | Swim (25pts @) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Noob | **10.000x** | **5 km** | **15 km** | **150 lengths** |
| **5** | Regular | **3.162x** | 15.8 km | 47.4 km | 474 lengths |
| **10** | Specialist| **1.000x** | 50 km | 150 km | 1,500 lengths |
| **15** | Master | **0.316x** | 158 km | 474 km | 4,740 lengths |
| **20** | Legend | **0.100x** | **500 km** | **1,500 km** | **15,000 lengths** |

> [!IMPORTANT]
> - **Relative Parity**: Cycling is exactly **3x** the distance of Running. Swimming is exactly **10 lengths** per km of Cycling.
> - **The Goal**: Whether you're a Noob doing a 5k run/15km cycle or a Legend doing a 500k run/1500km cycle, you earn exactly **25 points**.

---

## 🏗️ Seeding Logic & Mapping (Volume Based)

Seeding is now based on the "Effort Parity" principle. We place users where their current volume would earn them a rank-appropriate reward.

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
