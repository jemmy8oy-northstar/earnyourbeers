import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/logic/app_state.dart';

class ViceSettingsDialog extends StatefulWidget {
  const ViceSettingsDialog({super.key});

  @override
  State<ViceSettingsDialog> createState() => _ViceSettingsDialogState();
}

class _ViceSettingsDialogState extends State<ViceSettingsDialog> {
  late TextEditingController _emojiController;
  late ThemeMode _selectedTheme;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _emojiController = TextEditingController(text: state.viceEmoji);
    _selectedTheme = state.themeMode;
  }

  @override
  void dispose() {
    _emojiController.dispose();
    super.dispose();
  }

  void _save() {
    final state = context.read<AppState>();
    final emoji = _emojiController.text.trim();
    // Default to Pizza if empty
    state.updateVice(emoji.isEmpty ? '🍕' : emoji);
    state.updateTheme(_selectedTheme);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Your Vice'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji Input
            const Text(
              'Pick an Emoji',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emojiController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 48),
              maxLength: 2, // Emojis can be 2 chars (surrogate pairs)
              inputFormatters: [
                // Filter out standard keyboard characters (ASCII)
                FilteringTextInputFormatter.deny(RegExp(r'[\x00-\x7F]')),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '🍕',
                counterText: '', // Hide character counter
              ),
            ),
            const SizedBox(height: 16),

            // Quick Picks
            Wrap(
              spacing: 8,
              children: [
                _QuickPick(emoji: '🍕', onTap: () => _setEmoji('🍕')),
                _QuickPick(emoji: '🎮', onTap: () => _setEmoji('🎮')),
                _QuickPick(emoji: '🍩', onTap: () => _setEmoji('🍩')),
                _QuickPick(emoji: '🥤', onTap: () => _setEmoji('🥤')),
                _QuickPick(emoji: '🍫', onTap: () => _setEmoji('🍫')),
                _QuickPick(emoji: '☕', onTap: () => _setEmoji('☕')),
              ],
            ),
            const SizedBox(height: 24),

            // Theme Selection
            const Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Auto'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.wb_sunny),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.brightness_2),
                ),
              ],
              selected: {_selectedTheme},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                setState(() {
                  _selectedTheme = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Management',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<AppState>().resetApp();
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Reset App (Beta Testing)'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  void _setEmoji(String emoji) {
    setState(() {
      _emojiController.text = emoji;
    });
  }
}

class _QuickPick extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _QuickPick({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(emoji, style: const TextStyle(fontSize: 24)),
      onPressed: onTap,
    );
  }
}
