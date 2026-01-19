# Brainstorming: Earn Your Vices 😈

**Concept**: Use exercise to "buy" your guilty pleasures guilt-free.
**Strategy**: Prioritize non-alcohol vices to ensure App Store compliance and broaden appeal.

## The Authorized Vices 📝

The user can select one of the following "Currencies" to track their rewards in.

### 1. The Food Vices (Default) 🍕
*For the foodie - prioritized as requested.*
*   **Takeaway**: 1 Slice/Item (Icon: � Pizza)
*   **Sweet Treat**: 1 Donut/Cake (Icon: 🍩 Donut)

### 2. The Digital Vices 🎮
*Safe, universally appealing, and "time-based" logic.*
*   **Gaming**: 30 mins (Icon: � Gamepad)
*   **Netflix**: 1 Episode (Icon: 📺 TV)

### 3. The Liquid Vices 🥤
*Includes non-alcoholic options first.*
*   **Soda**: 1 Can/Glass (Icon: 🥤 Cup)
*   **Pint**: 1 Pint (Icon: 🍺 Beer Mug)
*   **Wine**: 1 Glass (Icon: 🍷 Wine Glass)

---

## Technical Implementation 🛠️

*   **ViceConfiguration**:
    *   `key`: Unique ID (e.g., `gaming`).
    *   `name`: Display Name.
    *   `icon`: Flutter IconData.
    *   `unitName`: "hours", "slices", "pints".
    *   `costPerCredit`: All generic "Credits" (earned by 5km run) = 1 Unit of Vice.

## App Store Safety ⚖️
*   **Default State**: App installs with **Gaming** selected.
*   **Onboarding**: "What's your Vice?" selection screen prioritizes Digital/Food options.
*   **Messaging**: "Earn your downtime" rather than "Earn your drink".
