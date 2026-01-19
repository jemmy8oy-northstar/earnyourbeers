# Rebrand Specification: Earn Your Vices

## 1. Vision & Strategy
**Concept**: "Earn Your Vices" acknowledges that we run to enjoy our guilty pleasures guilt-free.
**The "Pizza Defense"**: To ensure App Store compliance, the app is purely agnostic/neutral. It does not promote alcohol.
*   **Default State**: **Pizza 🍕**.
*   **Emoji Freedom**: Users define their own vice using ANY text/emoji.
*   **No Alcohol Presets**: We do NOT suggest alcohol. If a user types "Beer 🍺", that is strictly User Generated Content.

## 2. Onboarding Flow (Deferred)
*   For this stage, we assume the default is **Pizza 🍕**.
*   Users can customize via the **Settings Dialog**.

## 3. Data Migration (Backend)
### Database (`database.dart`)
*   **New Table**: `Settings`
    *   `key` (Text, Primary Key).
    *   `value` (Text).
    *   **Keys**: `vice_name`, `vice_emoji`, `theme_mode` (system/light/dark).

### App State (`app_state.dart`)
*   Add `viceEmoji` property.
*   Add `themeMode` property (ThemeMode).
*   Initialized from Database on launch.
*   `updateVice(String name, String emoji)`: Persists to DB.
*   `updateTheme(ThemeMode mode)`: Persists to DB.

## 4. UI Overhaul (Frontend)
### General
*   **App Bar**: "Earn Your Vices".

### Dashboard Screen
1.  **Header/AppBar**: Add **Settings Icon** action -> Opens `ViceSettingsDialog`.
2.  **Balance Display**:
    *   Display: `"${balance.toStringAsFixed(1)} ${state.viceEmoji}"` (e.g., "3.5 🍕").
3.  **Floating Action Buttons**:
    *   **Activity**: "Log Run 🏃".
    *   **Reward**: "Log ${state.viceEmoji}" (e.g., "Log 🍕").
4.  **History Cards**:
    *   All "Reward" logs display ONLY the Emoji (large size) instead of an icon + text.

### Settings Dialog
*   "Edit Your Vice".
*   "Pick Emoji": TextField (Emoji input).
*   "Quick Picks": Row of Chips (🍕, 🎮, 🍩, 🥤).
*   **Appearance**: Segmented Button (System | Light | Dark).

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
