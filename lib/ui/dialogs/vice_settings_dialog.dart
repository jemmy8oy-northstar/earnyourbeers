import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/logic/app_state.dart';

class ViceSettingsDialog extends StatefulWidget {
  const ViceSettingsDialog({super.key});

  @override
  State<ViceSettingsDialog> createState() => _ViceSettingsDialogState();
}

class _ViceSettingsDialogState extends State<ViceSettingsDialog> {
  late TextEditingController _emojiController;
  late TextEditingController _nameController;
  late ThemeMode _selectedTheme;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _emojiController = TextEditingController(text: state.viceEmoji);
    _nameController = TextEditingController(text: state.viceName);
    _selectedTheme = state.themeMode;
  }

  @override
  void dispose() {
    _emojiController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final state = context.read<AppState>();
    state.updateVice(_nameController.text, _emojiController.text);
    state.updateTheme(_selectedTheme);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Your Vice 😈'),
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '🍕',
              ),
            ),
            const SizedBox(height: 16),

            // Quick Picks
            Wrap(
              spacing: 8,
              children: [
                _QuickPick(
                  emoji: '🍕',
                  name: 'Pizza',
                  onTap: () => _updateVice('🍕', 'Pizza'),
                ),
                _QuickPick(
                  emoji: '🎮',
                  name: 'Gaming',
                  onTap: () => _updateVice('🎮', 'Gaming'),
                ),
                _QuickPick(
                  emoji: '🍩',
                  name: 'Treat',
                  onTap: () => _updateVice('🍩', 'Treat'),
                ),
                _QuickPick(
                  emoji: '🥤',
                  name: 'Soda',
                  onTap: () => _updateVice('🥤', 'Soda'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Name Input (Optional)
            const Text(
              'Name (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. Pizza',
              ),
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

  void _updateVice(String emoji, String name) {
    setState(() {
      _emojiController.text = emoji;
      _nameController.text = name;
    });
  }
}

class _QuickPick extends StatelessWidget {
  final String emoji;
  final String name;
  final VoidCallback onTap;

  const _QuickPick({
    required this.emoji,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(avatar: Text(emoji), label: Text(name), onPressed: onTap);
  }
}
