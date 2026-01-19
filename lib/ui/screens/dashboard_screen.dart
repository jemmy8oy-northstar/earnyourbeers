import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/logic/app_state.dart';
import '../../core/services/database.dart';
import '../../core/logic/pint_calculator.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _goNextWeek() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goPreviousWeek() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Stage 2: Use Weekly Balance logic with Time Travel
    final state = context.watch<AppState>();

    // Calculate Date range for header
    // Index 0 = Current, Index 1 = Last week
    final now = state.simulatedNow;
    final pageNow = now.subtract(Duration(days: 7 * _currentPageIndex));
    final monday = pageNow.subtract(Duration(days: pageNow.weekday - 1));
    final dateStr = '${monday.day}/${monday.month}';
    final headerText = _currentPageIndex == 0
        ? 'CURRENT WEEK'
        : 'WEEK OF $dateStr';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earn Your Beers 🍻'),
        actions: [
          // DEV: Time Travel Button
          IconButton(
            icon: const Icon(Icons.fast_forward),
            tooltip: 'Simulate +1 Week',
            onPressed: () {
              context.read<AppState>().simulateAdvanceWeek();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Simulated Time: ${context.read<AppState>().simulatedNow.toString().split('.')[0]}',
                  ),
                  behavior: SnackBarBehavior.fixed,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // STICKY HEADER
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white54),
                  onPressed: _goPreviousWeek,
                  tooltip: 'Previous Week',
                ),
                Text(
                  headerText,
                  style: const TextStyle(
                    color: Colors.white38,
                    letterSpacing: 1.5,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white54),
                  onPressed: _currentPageIndex > 0 ? _goNextWeek : null,
                  tooltip: 'Next Week',
                  color: _currentPageIndex > 0
                      ? Colors.white54
                      : Colors.transparent, // Hide if disabled
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              reverse: true, // Allows swiping Right to see "Past" (Index 1)
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                // Index 0 = Current, Index 1 = Last week, etc.
                final weekOffset = index;
                // Calculate "Now" for this specific page
                final pageNow = state.simulatedNow.subtract(
                  Duration(days: 7 * weekOffset),
                );

                return WeeklyPage(
                  weekOffset: weekOffset,
                  pageNow: pageNow,
                  key: ValueKey(weekOffset),
                );
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
            },
            label: const Text('Pint'),
            icon: const Icon(Icons.sports_bar),
            backgroundColor: AppTheme.primaryBeer,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () {
              context.read<AppState>().addActivity('Run', 5.0);
            },
            label: const Text('Run (5k)'),
            icon: const Icon(Icons.directions_run),
            backgroundColor: AppTheme.primaryBeer,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () {
              context.read<AppState>().addActivity('Cycle', 15.0);
            },
            label: const Text('Cycle (15k)'),
            icon: const Icon(Icons.directions_bike),
            backgroundColor: AppTheme.primaryBeer,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () {
              context.read<AppState>().addActivity('Swim', 30.0);
            },
            label: const Text('Swim (30)'),
            icon: const Icon(Icons.pool),
            backgroundColor: AppTheme.primaryBeer,
          ),
        ],
      ),
    );
  }
}

class WeeklyPage extends StatefulWidget {
  final int weekOffset;
  final DateTime pageNow;

  const WeeklyPage({
    super.key,
    required this.weekOffset,
    required this.pageNow,
  });

  @override
  State<WeeklyPage> createState() => _WeeklyPageState();
}

class _WeeklyPageState extends State<WeeklyPage> {
  final GlobalKey<AnimatedListState> _historyListKey =
      GlobalKey<AnimatedListState>();
  List<dynamic> _previousHistory = [];
  bool _isDeleting = false;

  /// Filter logs for THIS week
  List<dynamic> _getWeeklyLogs(List<dynamic> allLogs) {
    final now = widget.pageNow;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(
      const Duration(days: 7),
    ); // The following Monday

    return allLogs.where((item) {
      final ts = (item as dynamic).timestamp;
      return (ts.isAfter(startOfWeek) || ts.isAtSameMomentAs(startOfWeek)) &&
          ts.isBefore(endOfWeek);
    }).toList();
  }

  /// Get history items (all except the most recent OF THIS WEEK)
  List<dynamic> _getHistory(List<dynamic> weeklyLogs) {
    return weeklyLogs.length > 1 ? weeklyLogs.sublist(1) : [];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // 1. Get ALL logs from state (State has everything)
    final allLogs = state.logs;

    // 2. Filter for THIS page's week
    final weeklyLogs = _getWeeklyLogs(allLogs);

    // 3. Calculate Balance for THIS page's week
    final weeklyActivities = weeklyLogs.whereType<Activity>().toList();
    final weeklyDrinks = weeklyLogs.whereType<Drink>().toList();
    final balance = PintCalculator.calculateBalance(
      weeklyActivities,
      weeklyDrinks,
    );

    // 4. Handle List Sync using addPostFrameCallback to avoid build-time side effects
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncHistoryList(weeklyLogs);
      }
    });

    final activeItem = weeklyLogs.isNotEmpty ? weeklyLogs[0] : null;
    final history = _getHistory(weeklyLogs);

    return Column(
      children: [
        const SizedBox(height: 20),
        const SizedBox(height: 10),
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
              ? 'POINTS IN CREDIT'
              : balance < 0
              ? 'POINTS IN DEBT'
              : 'SQUARE',
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
          child: weeklyLogs.isEmpty
              ? const Center(
                  child: Text(
                    'No activity this week. 🍻',
                    style: TextStyle(color: Colors.white24),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // ACTIVE CARD
                      SizedBox(
                        height: 140,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) {
                            // TRUE CUBOID ROTATION Logic
                            final isEntering =
                                animation.status == AnimationStatus.forward ||
                                animation.status == AnimationStatus.completed;

                            return AnimatedBuilder(
                              animation: animation,
                              child: child,
                              builder: (context, child) {
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
                                  ..translate(0.0, 0.0, 70.0)
                                  ..rotateX(angle)
                                  ..translate(0.0, 0.0, -70.0);
                                return Transform(
                                  transform: transform,
                                  alignment: Alignment.center,
                                  child: child,
                                );
                              },
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
                                  onDelete: () =>
                                      _deleteItem(context, activeItem),
                                  onEdit: () =>
                                      _showEditDialog(context, activeItem),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      // HISTORY LIST
                      if (history.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 8, top: 16, bottom: 8),
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
    );
  }

  void _syncHistoryList(List<dynamic> currentWeeklyLogs) {
    final currentHistory = _getHistory(currentWeeklyLogs);

    // Sync insert
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

  void _deleteItem(BuildContext context, dynamic item) {
    setState(() => _isDeleting = true);
    final id = item is Activity ? item.id : (item as Drink).id;
    if (item is Activity) {
      context.read<AppState>().deleteActivity(id);
    } else {
      context.read<AppState>().deleteDrink(id);
    }
    // We rely on rebuild to update UI, but AnimatedList might need manual removal?
    // Since we destroy the list on page change, or rebuild significantly,
    // minimal support here is fine for now as long as it doesn't crash.
  }

  Widget _buildHistoryTile(dynamic item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: animation,
        child: _HistoryTile(item: item),
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic item) {
    final isActivity = item is Activity;
    final type = isActivity ? item.type : 'Pint';
    final unit = isActivity ? (type == 'Swim' ? 'lengths' : 'km') : 'pints';

    final controller = TextEditingController(
      text: item.amount % 1 == 0
          ? item.amount.toInt().toString()
          : item.amount.toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${isActivity ? '$type ($unit)' : 'Pints'}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter amount...',
            suffixText: unit,
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
        ? '${amount.toStringAsFixed(1)} ${(item).type == 'Swim' ? 'lengths' : 'km'} ${(item).type}'
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
                  !isActivity
                      ? Icons.sports_bar
                      : ((item).type == 'Cycle'
                            ? Icons.directions_bike
                            : ((item).type == 'Swim'
                                  ? Icons.pool
                                  : Icons.directions_run)),
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
                      if (amount > 0.5) {
                        state.updateActivity(item, amount - 0.5);
                      }
                    } else {
                      if (amount > 1) {
                        state.updateDrink(item as Drink, amount - 1);
                      }
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

  const _HistoryTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isActivity = item is Activity;
    final amount = isActivity ? item.amount : (item as Drink).amount;

    final label = isActivity
        ? '${amount.toStringAsFixed(1)} ${(item).type == 'Swim' ? 'lengths' : 'km'} ${(item).type}'
        : '${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(1)} Pint${amount == 1 ? '' : 's'}';

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(
        !isActivity
            ? Icons.sports_bar
            : ((item).type == 'Cycle'
                  ? Icons.directions_bike
                  : ((item).type == 'Swim'
                        ? Icons.pool
                        : Icons.directions_run)),
        color: AppTheme.primaryBeer.withOpacity(0.7),
        size: 20,
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      trailing: Text(
        '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(color: Colors.white24, fontSize: 12),
      ),
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
