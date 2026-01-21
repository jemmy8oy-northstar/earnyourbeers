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

## 📈 League-Specific Difficulty (The Standard Shift)

To ensure "Elite" tiers remain earned and prestigious, the reward multipliers scale inversely with the user's tier.

| Division | Tier Range | Multiplier | Run (pts/km) | Cycle (pts/km) |
| :--- | :--- | :--- | :--- | :--- |
| **Apprenticeship** | 0 - 4 | **1.0x** | 0.50 | 0.067 |
| **Practice** | 5 - 9 | **0.9x** | 0.45 | 0.060 |
| **Mastery** | 10 - 14 | **0.8x** | 0.40 | 0.053 |
| **Legacy** | 15 - 20 | **0.7x** | 0.35 | 0.046 |

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
