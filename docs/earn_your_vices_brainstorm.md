# Brainstorming: Earn Your Vices 😈

**Concept**: Use exercise to "buy" your guilty pleasures guilt-free.
**Strategy**: Prioritize non-alcohol vices to ensure App Store compliance and broaden appeal.

## The Authorized Vices 📝

## The Emoji Freedom Concept 🤠

Instead of us defining what a "Vice" is, **the user defines it**.

*   **Mechanism**: "Pick an Emoji to represent your reward."
*   **User Choice**:
    *   User selects: 🍺 -> We display "3.5 🍺".
    *   User selects: 🍰 -> We display "3.5 🍰".
    *   User selects: 🍆 -> We display "3.5 🍆" (We don't judge).
*   **Measurement**: We stick to a standard "Credit" (1 Credit = 5km). Currently 1 Credit = 1 Emoji Unit.

### Benefits 🌟
1.  **Ultimate Safety**: We aren't promoting alcohol. The *user* is choosing an emoji. We are just a calculator.
2.  **Zero Maintenance**: No need to add "Soda" or "Vape" or "Books".
3.  **Global Appeal**: Emojis are universal.

### The "Default"
*   We can still provide presets for quick selection (e.g. "Gaming 🎮", "Treat 🍩", "Soda 🥤"), but the core data model is just `String emoji`.

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
