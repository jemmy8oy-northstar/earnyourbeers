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
  final GlobalKey<AnimatedListState> _historyListKey =
      GlobalKey<AnimatedListState>();
  List<dynamic> _previousHistory = [];
  bool _isDeleting =
      false; // Track if last action was delete (for rotation direction)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncHistoryList();
  }

  /// Get history items (all except the most recent)
  List<dynamic> _getHistory(List<dynamic> logs) {
    return logs.length > 1 ? logs.sublist(1) : [];
  }

  void _syncHistoryList() {
    final logs = context.read<AppState>().logs;
    final currentHistory = _getHistory(logs);

    // Find new items in history (items that weren't there before)
    for (int i = 0; i < currentHistory.length; i++) {
      final item = currentHistory[i];
      final itemId = item is Activity ? item.id : (item as Drink).id;
      final wasInPrevious = _previousHistory.any((prev) {
        final prevId = prev is Activity ? prev.id : (prev as Drink).id;
        return prevId == itemId;
      });
      if (!wasInPrevious) {
        _historyListKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 400),
        );
      }
    }

    _previousHistory = List.from(currentHistory);
  }

  void _deleteItem(dynamic item) {
    setState(() => _isDeleting = true); // Set delete direction for animation
    final logs = context.read<AppState>().logs;
    final isActive = logs.isNotEmpty && logs[0] == item;
    final id = item is Activity ? item.id : (item as Drink).id;
    final history = _getHistory(logs);

    if (isActive) {
      // Deleting the active item
      // The top history item will become the new active, so animate it out of history
      if (history.isNotEmpty) {
        final topHistoryItem = history[0];
        _historyListKey.currentState?.removeItem(
          0,
          (context, animation) =>
              _buildHistoryTile(topHistoryItem, animation, isRemoving: true),
          duration: const Duration(milliseconds: 400),
        );
      }

      // Actually delete from state
      if (item is Activity) {
        context.read<AppState>().deleteActivity(id);
      } else {
        context.read<AppState>().deleteDrink(id);
      }
      // Update history tracking (new history is logs[1:] after active is removed)
      _previousHistory = _getHistory(context.read<AppState>().logs);
    } else {
      // Deleting from history list - animate out
      final historyIndex = history.indexOf(item);
      if (historyIndex >= 0) {
        _historyListKey.currentState?.removeItem(
          historyIndex,
          (context, animation) =>
              _buildHistoryTile(item, animation, isRemoving: true),
          duration: const Duration(milliseconds: 400),
        );
      }
      // Actually delete from state
      if (item is Activity) {
        context.read<AppState>().deleteActivity(id);
      } else {
        context.read<AppState>().deleteDrink(id);
      }
      _previousHistory = _getHistory(context.read<AppState>().logs);
    }
  }

  Widget _buildHistoryTile(
    dynamic item,
    Animation<double> animation, {
    bool isRemoving = false,
  }) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: animation,
        child: _HistoryTile(
          item: item,
          onDelete: isRemoving ? null : () => _deleteItem(item),
          onEdit: () => _showEditDialog(context, item),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<AppState>().balance;
    final logs = context.watch<AppState>().logs;
    final activeItem = logs.isNotEmpty ? logs[0] : null;
    final history = _getHistory(logs);

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

          // Activity Feed
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Text(
                      'No activity yet. Get moving! 🍻',
                      style: TextStyle(color: Colors.white24),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // ACTIVE CARD - Fixed height, TRUE CUBOID rotation
                        SizedBox(
                          height:
                              140, // Fixed height so history list doesn't jump
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            transitionBuilder: (child, animation) {
                              // TRUE CUBOID ROTATION
                              const double halfHeight = 70.0;

                              // Detect if this is the entering (new) or exiting (old) widget
                              // by checking if animation is driving forward or dismissed/reversing
                              final isEntering =
                                  animation.status == AnimationStatus.forward ||
                                  animation.status == AnimationStatus.completed;

                              return AnimatedBuilder(
                                animation: animation,
                                child: child,
                                builder: (context, child) {
                                  // Flip rotation direction based on add vs delete
                                  final direction = _isDeleting ? 1.0 : -1.0;
                                  double angle;
                                  if (isEntering) {
                                    angle =
                                        -direction *
                                        (1.0 - animation.value) *
                                        1.5708;
                                  } else {
                                    angle =
                                        direction *
                                        (1.0 - animation.value) *
                                        1.5708;
                                  }

                                  final transform = Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..translate(
                                      0.0,
                                      0.0,
                                      halfHeight,
                                    ) // Push axis FORWARD
                                    ..rotateX(angle)
                                    ..translate(
                                      0.0,
                                      0.0,
                                      -halfHeight,
                                    ); // Push card BACK

                                  return Transform(
                                    transform: transform,
                                    alignment: Alignment.center,
                                    child: child,
                                  );
                                },
                              );
                            },
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            },
                            child: activeItem != null
                                ? _ActiveCard(
                                    key: ValueKey(
                                      activeItem is Activity
                                          ? activeItem.id
                                          : (activeItem as Drink).id,
                                    ),
                                    item: activeItem,
                                    onDelete: () => _deleteItem(activeItem),
                                    onEdit: () =>
                                        _showEditDialog(context, activeItem),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),

                        // HISTORY LIST - AnimatedList of tiles only
                        if (history.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 8,
                              top: 16,
                              bottom: 8,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'HISTORY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: AnimatedList(
                              key: _historyListKey,
                              initialItemCount: history.length,
                              itemBuilder: (context, index, animation) {
                                if (index >= history.length)
                                  return const SizedBox.shrink();
                                return _buildHistoryTile(
                                  history[index],
                                  animation,
                                );
                              },
                            ),
                          ),
                        ] else
                          const Spacer(),
                      ],
                    ),
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
              setState(() => _isDeleting = false); // Add direction
              context.read<AppState>().addDrink(1.0);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _syncHistoryList(),
              );
            },
            label: const Text('Log Pint'),
            icon: const Icon(Icons.sports_bar),
            backgroundColor: AppTheme.primaryBeer,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () {
              setState(() => _isDeleting = false); // Add direction
              context.read<AppState>().addActivity(5.0);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _syncHistoryList(),
              );
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

/// The active card - always displayed as a full card
class _ActiveCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ActiveCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isActivity = item is Activity;
    final amount = isActivity ? item.amount : (item as Drink).amount;
    final state = context.read<AppState>();

    final label = isActivity
        ? '${amount.toStringAsFixed(1)} km Run'
        : '${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(1)} Pint${amount == 1 ? '' : 's'}';

    return Card(
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
                _ActionButton(icon: Icons.delete_outline, onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// History tile - always displayed as a compact tile
class _HistoryTile extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onDelete;
  final VoidCallback onEdit;

  const _HistoryTile({required this.item, this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isActivity = item is Activity;
    final amount = isActivity ? item.amount : (item as Drink).amount;

    final label = isActivity
        ? '${amount.toStringAsFixed(1)} km Run'
        : '${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(1)} Pint${amount == 1 ? '' : 's'}';

    return ListTile(
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
      onTap: onEdit,
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
