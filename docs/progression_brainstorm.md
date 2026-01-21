# Brainstorming: Leagues & Progression (Earn Your Vices)

Now that we have pivoted to **"Earn Your Vices"**, we need a progression system that feels premium, engaging, and neutral (avoiding beer/alcohol branding).

## Theme: "The Path of Discipline"

The progression system reflects the user's journey of "earning" their rewards through sustained physical discipline.

### 💎 The Elite 20 (Finalized Progression)

The journey consists of **20 tiers** grouped into **4 thematic divisions**. This ensures a long-term sense of achievement from the first log to "Legend" status.

#### **Division I: The Apprenticeship**
*The focus is on establishing the daily habit and understanding the loop.*

| Tier | Name | Vibe |
| :--- | :--- | :--- |
| **1** | **Noob** | Entry level. Welcome to the loop. |
| **2** | **Novice** | Breaking the seal on intentional effort. |
| **3** | **Weekender** | Finding rhythm in the gaps. |
| **4** | **Rookie** | Demonstrating early consistency. |
| **5** | **Apprentice** | Understanding the architecture of discipline. |

#### **Division II: The Practice**
*The habit is formed; the focus shifts to pure effort and work ethic.*

| Tier | Name | Vibe |
| :--- | :--- | :--- |
| **6** | **Regular** | A familiar face in the league of discipline. |
| **7** | **Grinder** | Pure volume and tireless work ethic. |
| **8** | **Athlete** | Goals and performance take center stage. |
| **9** | **Competitor** | Actively pushing personal bests. |
| **10** | **Professional** | Mastery of the foundational cycle. |

#### **Division III: The Mastery**
*The level of a high-tier performer with specialized focus.*

| Tier | Name | Vibe |
| :--- | :--- | :--- |
| **11** | **Specialist** | Refined focus and tactical discipline. |
| **12** | **Relentless** | Unstoppable, reliable, and consistent. |
| **13** | **Veteran** | Proven performance over long durations. |
| **14** | **Expert** | Deep intuition of the reward-effort balance. |
| **15** | **Champion** | Sustained peak excellence. |

#### **Division IV: The Legacy**
*The absolute peak. Psychological and physical mastery.*

| Tier | Name | Vibe |
| :--- | :--- | :--- |
| **16** | **Master** | Total psychological command over the loop. |
| **17** | **Grandmaster** | Elevated technical mastery and insight. |
| **18** | **Elite** | Standing among the top 1% of trackers. |
| **19** | **Titan** | A monumental presence in the system. |
| **20** | **Legend** | Eternal residency in the Hall of Vices. |

---

## The XP Logic: "Weekly Settlement"

Progression is not manual. Instead, the "League Tally" is settled automatically the first time a user opens the app in a new week.

### 1. The Weekly Breakdown
When the user arrives in a new week, a **Settlement Report** is shown:
- **Last Active Week Recap**: "You earned +28.5 🍕 last week."
- **Net Impact**: This value is added directly to your **League Tally**.

### 2. Tier Shifts (Promotion/Demotion)
Rank changes depend on the accumulated **League Tally**:
- **Promotion (+25)**: Reaching +25 points triggers a Single Promotion.
- **Double Promotion (+50)**: Reaching +50 points in a single settlement triggers a Double Promotion (skipping a tier). 
- **Demotion (-25)**: If the tally drops below -25 points, the user is demoted one tier.

> [!TIP]
> **Multi-tier Logic**: +50 points is significantly harder to achieve than 25 in two separate weeks, as the difficulty of earning points effectively increases in higher tiers (implied difficulty boost). Skipping a tier honors this "high-density" effort.

### 3. The "Vaulting" Mechanic
Upon promotion, the points used (25 or 50) are "burnt" and added to your **Lifetime Vaulted XP**. Your League Tally resets (carrying over any remainder).

---

## The UI/UX Experience

The progression system should feel like a premium, persistent part of the user's journey, not just a hidden stat.

### 1. Dashboard Visibility (Always-On)
- **Rank Header**: A dedicated "League Banner" at the top of the main dashboard showing your Division and Title (e.g., "Practice II: Athlete").
- **Tally Progress Bar**: A sleek, persistent bar that tracks the `-25 to +25` range. 
  - **Visual Feedback**: The bar glows gold as it nears +25 (Promotion Zone) and pulses red as it nears -25 (Danger Zone).
- **Division Theming**: The entire dashboard (or parts of it) should subtly shift colors based on your Division:
  - **I: Apprenticeship** (Quartz)
  - **II: Practice** (Emerald)
  - **III: Mastery** (Sapphire)
  - **IV: Legacy** (Amethyst/Obsidion)

### 2. The Weekly Settlement Sequence
When the user first logs in during a new week, we present a high-energy **Settlement Report**:

1. **Step 1: The Recap**: "Last week you clocked 25km and earned 5.0 Vices."
2. **Step 2: The Tally Drop**: An animation showing the last week's net points "falling" into the League Tally progress bar.
3. **Step 3: The Outcome**:
   - **Stable**: "Position Secured."
   - **Promotion**: A high-impact "Rank Up" screen with confetti and sound effects.
   - **Double Promotion**: A special "Ascension" screen for the +50 point tier-skip.
   - **Demotion**: A supportive "Regroup" summary for a fresh start.
4. **Step 4: Completion**: Clear "Start New Week" button to transition to the current active dashboard.

---

## Technical Feasibility
- **Detection**: Use `AppState` to compare `lastSettledDate` with `currentWeekStart`.
- **Logic**: Process the settlement *before* updating the active week UI to ensure the report uses correct "Last Week" data.
