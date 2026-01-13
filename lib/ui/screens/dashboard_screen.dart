import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/logic/app_state.dart';
import '../../core/models/activity.dart';
import '../../core/models/drink.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<dynamic> _previousLogs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync AnimatedList with state changes
    _syncList();
  }

  void _syncList() {
    final currentLogs = context.read<AppState>().logs;

    // Find insertions (items in current but not in previous)
    for (int i = 0; i < currentLogs.length; i++) {
      final item = currentLogs[i];
      final itemId = item is Activity ? item.id : (item as Drink).id;
      final wasInPrevious = _previousLogs.any((prev) {
        final prevId = prev is Activity ? prev.id : (prev as Drink).id;
        return prevId == itemId;
      });
      if (!wasInPrevious) {
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 500),
        );
      }
    }

    _previousLogs = List.from(currentLogs);
  }

  void _removeItem(int index, dynamic item) {
    final removedItem = item;
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildItem(removedItem, animation, isRemoving: true),
      duration: const Duration(milliseconds: 500),
    );

    // Actually delete from state
    final id = item is Activity ? item.id : (item as Drink).id;
    if (item is Activity) {
      context.read<AppState>().deleteActivity(id);
    } else {
      context.read<AppState>().deleteDrink(id);
    }
    _previousLogs = List.from(context.read<AppState>().logs);
  }

  Widget _buildItem(
    dynamic item,
    Animation<double> animation, {
    bool isRemoving = false,
  }) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: animation,
        child: _LogItemContent(
          item: item,
          isRemoving: isRemoving,
          onEdit: () => _showEditDialog(context, item),
          onDelete: isRemoving
              ? null
              : () {
                  final currentLogs = context.read<AppState>().logs;
                  final index = currentLogs.indexOf(item);
                  if (index >= 0) _removeItem(index, item);
                },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<AppState>().balance;
    final logs = context.watch<AppState>().logs;

    return Scaffold(
      appBar: AppBar(title: const Text('Earn Your Beers 🍻')),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            balance.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBeer,
            ),
          ),
          Text(
            balance > 0
                ? 'PINTS IN CREDIT'
                : balance < 0
                ? 'PINTS IN DEBT'
                : 'SQUARE AT THE BAR',
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 2,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 30),
          const Divider(indent: 32, endIndent: 32),
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Text(
                      'No activity yet. Get moving! 🍻',
                      style: TextStyle(color: Colors.white24),
                    ),
                  )
                : AnimatedList(
                    key: _listKey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    initialItemCount: logs.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= logs.length) return const SizedBox.shrink();
                      return _buildItem(logs[index], animation);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              context.read<AppState>().addDrink(1.0);
              // Trigger sync on next frame
              WidgetsBinding.instance.addPostFrameCallback((_) => _syncList());
            },
            label: const Text('Log Pint'),
            icon: const Icon(Icons.sports_bar),
            backgroundColor: AppTheme.primaryBeer,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () {
              context.read<AppState>().addActivity(5.0);
              // Trigger sync on next frame
              WidgetsBinding.instance.addPostFrameCallback((_) => _syncList());
            },
            label: const Text('Log Run (5k)'),
            icon: const Icon(Icons.directions_run),
            backgroundColor: AppTheme.primaryBeer,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic item) {
    final isActivity = item is Activity;
    final controller = TextEditingController(
      text: item.amount % 1 == 0
          ? item.amount.toInt().toString()
          : item.amount.toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${isActivity ? 'Run (km)' : 'Pints'}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter amount...',
            suffixText: isActivity ? 'km' : 'pints',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val >= 0) {
                if (isActivity) {
                  context.read<AppState>().updateActivity(item, val);
                } else {
                  final rounded = (val * 10).roundToDouble() / 10;
                  context.read<AppState>().updateDrink(item as Drink, rounded);
                }
              }
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}

/// The content widget for a log item. Animation is handled by AnimatedList.
/// This widget watches state directly to react to position changes.
class _LogItemContent extends StatelessWidget {
  final dynamic item;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isRemoving; // If true, skip watching state (item is being removed)

  const _LogItemContent({
    required this.item,
    required this.onEdit,
    this.onDelete,
    this.isRemoving = false,
  });

  @override
  Widget build(BuildContext context) {
    // Watch state to reactively update when position changes
    final logs = isRemoving ? <dynamic>[] : context.watch<AppState>().logs;
    final isMostRecent = !isRemoving && logs.isNotEmpty && logs[0] == item;

    final isActivity = item is Activity;
    final amount = isActivity ? item.amount : (item as Drink).amount;
    final state = context.read<AppState>();

    final label = isActivity
        ? '${amount.toStringAsFixed(1)} km Run'
        : '${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(1)} Pint${amount == 1 ? '' : 's'}';

    final activeCard = Card(
      key: const ValueKey('active'),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: Colors.white.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isActivity ? Icons.directions_run : Icons.sports_bar,
                  color: AppTheme.primaryBeer,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Logged at ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.remove,
                  onPressed: () {
                    if (isActivity) {
                      if (amount > 0.5)
                        state.updateActivity(item, amount - 0.5);
                    } else {
                      if (amount > 1)
                        state.updateDrink(item as Drink, amount - 1);
                    }
                  },
                ),
                _ActionButton(
                  icon: Icons.add,
                  onPressed: () {
                    if (isActivity) {
                      state.updateActivity(item, amount + 0.5);
                    } else {
                      state.updateDrink(item as Drink, amount + 1);
                    }
                  },
                ),
                _ActionButton(icon: Icons.edit, onPressed: onEdit),
                if (onDelete != null)
                  _ActionButton(
                    icon: Icons.delete_outline,
                    onPressed: onDelete!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    final historyTile = ListTile(
      key: const ValueKey('history'),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(
        isActivity ? Icons.directions_run : Icons.sports_bar,
        color: AppTheme.primaryBeer.withOpacity(0.7),
        size: 20,
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white24, fontSize: 12),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close, size: 14, color: Colors.white10),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );

    return AnimatedCrossFade(
      firstChild: activeCard,
      secondChild: historyTile,
      crossFadeState: isMostRecent
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 500),
      sizeCurve: Curves.easeInOutCubic,
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeOut,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 14),
        onPressed: onPressed,
      ),
    );
  }
}
