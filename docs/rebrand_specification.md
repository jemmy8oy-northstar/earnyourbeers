# Rebrand Specification: Earn Your Vices 😈

## 1. Vision & Strategy
**Concept**: "Earn Your Vices" acknowledges that we run to enjoy our guilty pleasures guilt-free.
**The "Pizza Defense"**: To ensure App Store compliance, the app is purely agnostic/neutral. It does not promote alcohol.
*   **Default State**: **Pizza 🍕**.
*   **Emoji Freedom**: Users define their own vice using ANY text/emoji.
*   **No Alcohol Presets**: We do NOT suggest alcohol. If a user types "Beer 🍺", that is strictly User Generated Content.

## 2. Onboarding Flow
1.  **Welcome**: Title "Earn Your Vices". "Run 5km. Earn 1 Credit."
2.  **Vice Selection**:
    *   **Headline**: "What's your Poison?"
    *   **Default**: Pizza 🍕
    *   **Presets**: 🎮 Gaming, 🍩 Treat, 🥤 Soda, 📺 TV.
    *   **Custom**: TextField allowing full custom entry.
    *   **NO Alcohol Presets**.

## 3. Data Migration (Backend)
### Database (`database.dart`)
*   **New Table**: `Settings`
    *   `key` (Text, Primary Key) e.g., 'vice_name', 'vice_emoji'.
    *   `value` (Text).
*   **Settings Keys**:
    *   `vice_name`: String (Default: 'Pizza')
    *   `vice_emoji`: String (Default: '🍕')
    *   `onboarding_complete`: Boolean (String 'true'/'false')

### App State (`app_state.dart`)
*   Add `viceName` and `viceEmoji` properties.
*   Initialized from Database on launch.
*   `updateVice(String name, String emoji)`: Persists to DB and updates State.

## 4. UI Overhaul (Frontend)
### General
*   **App Bar**: Rename to "Earn Your Vices 😈".
*   **Color Theme**: Maintain dark/premium aesthetic but potentially shift accent color (TBD, keep Red/Amber for now).

### Dashboard Screen
1.  **Header/AppBar**: Add **Settings Icon** action -> Opens `ViceSettingsDialog`.
2.  **Balance Display**:
    *   Logic: `(Total KM / 5) - Spent`.
    *   Display: `"${balance.toStringAsFixed(1)} ${state.viceEmoji}"` (e.g., "3.5 🍕").
3.  **Floating Action Buttons**:
    *   **Activity**: "Log Run 🏃".
    *   **Reward**: "Log ${state.viceName} ${state.viceEmoji}" (e.g., "Log Pizza 🍕").
4.  **History Cards**:
    *   Replace `Icons.local_drink` (Beer Icon) with `Text(state.viceEmoji, fontSize: ...)` for all reward logs.
    *   For Activity logs, keep generic icons (Run 🏃, Cycle 🚴) or use Emojis there too for consistency? (Let's keep specific Icons for Activities for now, but Emojis for Vices).

### Settings Dialog
*   Simple Form Dialog.
*   "Name your Vice": TextField.
*   "Pick Emoji": TextField (limit 1 char ideally, or just text).
*   "Quick Picks": Row of Chips (🍕, 🎮, 🍩, 🥤).

## 5. App Store Metadata
*   **Name**: Earn Your Vices
*   **Subtitle**: Guilt-free Motivation
*   **Keywords**: Run, rewards, pizza, gaming, tracker.
*   **Rating**: 12+ (Safe).

## 6. Development Checklist
- [ ] Create `Settings` table.
- [ ] Update `AppState` to load/save settings.
- [ ] Implement `OnboardingScreen` (check `!onboarding_complete`).
- [ ] Update `DashboardScreen` UI (AppBar, FAB, Cards).
- [ ] Verify "Pint" does not appear in code/UI.
