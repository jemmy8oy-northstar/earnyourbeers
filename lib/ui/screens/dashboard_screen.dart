import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../core/logic/app_state.dart';
import '../../core/services/database.dart';
import '../../core/logic/pint_calculator.dart';
import '../theme.dart';
import '../dialogs/vice_settings_dialog.dart';
import '../dialogs/weekly_settlement_dialog.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  StreamSubscription? _settlementSubscription;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Listen for settlements
    final appState = context.read<AppState>();
    _settlementSubscription = appState.settlementStream.listen((report) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false, // Force them to see the report
          builder: (dialogContext) => WeeklySettlementDialog(report: report),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _settlementSubscription?.cancel();
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
    // Need access to limit check here, but safe to just try next page if constrained by PageView
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Stage 2: Use Weekly Balance logic with Time Travel
    final state = context.watch<AppState>();
    final maxPages = state.historyPageCount;
    final canGoBack = _currentPageIndex < maxPages - 1;

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
        title: const Text('Earn Your Vices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              final appState = context.read<AppState>();
              showDialog(
                context: context,
                builder: (dialogContext) =>
                    ChangeNotifierProvider<AppState>.value(
                      value: appState,
                      child: const ViceSettingsDialog(),
                    ),
              );
            },
          ),
          // DEV: Time Travel Button (tap = +1 week, long-press = reset)
          if (kDebugMode)
            InkWell(
              onTap: () {
                context.read<AppState>().simulateAdvanceWeek();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Simulated: ${context.read<AppState>().simulatedNow.toString().split('.')[0]}',
                    ),
                    behavior: SnackBarBehavior.fixed,
                  ),
                );
              },
              onLongPress: () async {
                final messenger = ScaffoldMessenger.of(context);
                await context.read<AppState>().resetTimeTravel();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Time Travel Reset ⏱️'),
                    behavior: SnackBarBehavior.fixed,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.fast_forward),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const _LeagueBanner(),
          // STICKY HEADER
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: canGoBack,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    onPressed: _goPreviousWeek,
                    tooltip: 'Previous Week',
                  ),
                ),
                Text(
                  headerText,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.38),
                    letterSpacing: 1.5,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Visibility(
                  visible: _currentPageIndex > 0,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    onPressed: _goNextWeek,
                    tooltip: 'Next Week',
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: maxPages,
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

    // For current week (weekOffset == 0): first item is active/editable
    // For past weeks (weekOffset > 0): all items are read-only history
    final isCurrentWeek = widget.weekOffset == 0;
    final activeItem = isCurrentWeek && weeklyLogs.isNotEmpty
        ? weeklyLogs[0]
        : null;
    final history = isCurrentWeek ? _getHistory(weeklyLogs) : weeklyLogs;

    return Column(
      children: [
        if (isCurrentWeek) _ActionRow(state: state),
        const SizedBox(height: 20),
        Text(
          '${balance.toStringAsFixed(1)} ${state.viceEmoji}',
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
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 2,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.54),
          ),
        ),
        const SizedBox(height: 30),
        const Divider(indent: 32, endIndent: 32),

        // Activity Feed
        Expanded(
          child: weeklyLogs.isEmpty
              ? Center(
                  child: Text(
                    'No activity this week.',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.24),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // ACTIVE CARD (only for current week)
                      if (activeItem != null)
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
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 16, bottom: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'HISTORY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.24),
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
        title: Text(
          isActivity
              ? 'Edit $type ($unit)'
              : 'Edit ${context.read<AppState>().viceEmoji}',
        ),
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
        : '${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(1)} ${state.viceEmoji}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                !isActivity
                    ? Text(
                        state.viceEmoji,
                        style: const TextStyle(fontSize: 28),
                      )
                    : Icon(
                        (item).type == 'Cycle'
                            ? Icons.directions_bike
                            : ((item).type == 'Swim'
                                  ? Icons.pool
                                  : Icons.directions_run),
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
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Logged at ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.38),
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
        : '${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(1)} ${context.read<AppState>().viceEmoji}';

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: !isActivity
          ? Text(
              context.read<AppState>().viceEmoji,
              style: const TextStyle(fontSize: 20),
            )
          : Icon(
              ((item).type == 'Cycle'
                  ? Icons.directions_bike
                  : ((item).type == 'Swim'
                        ? Icons.pool
                        : Icons.directions_run)),
              color: AppTheme.primaryBeer.withOpacity(0.7),
              size: 20,
            ),
      title: Text(
        label,
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.70),
          fontSize: 14,
        ),
      ),
      trailing: Text(
        '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.24),
          fontSize: 12,
        ),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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

class _LeagueBanner extends StatelessWidget {
  const _LeagueBanner();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tier = state.currentTier;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tier.color.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: tier.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tier.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shield, color: tier.color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tier.division.toUpperCase()} ${(_stateToDivisionRank(state.currentLevel) + 1)}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: tier.color,
                      ),
                    ),
                    Text(
                      tier.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${state.leagueTally.toStringAsFixed(1)} pts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: state.tallyProgress,
              backgroundColor: tier.color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(tier.color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  int _stateToDivisionRank(int level) {
    return level % 5;
  }
}

class _ActionRow extends StatelessWidget {
  final AppState state;
  const _ActionRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _ViceActionCard(state: state)),
          const SizedBox(width: 8),
          Expanded(child: _ActivityRow(state: state)),
        ],
      ),
    );
  }
}

class _ViceActionCard extends StatelessWidget {
  final AppState state;
  const _ViceActionCard({required this.state});

  @override
  Widget build(BuildContext context) {
    // Count how many vices this week
    final now = state.simulatedNow;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final weeklyDrinks = state.logs
        .whereType<Drink>()
        .where((d) => d.timestamp.isAfter(startOfWeek))
        .fold<double>(0, (sum, d) => sum + d.amount);

    return InkWell(
      onTap: () => state.addDrink(1.0),
      onLongPress: () => _showCustomViceDialog(context),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(state.viceEmoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weeklyDrinks.toInt()}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'CONSUMED',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add_circle, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomViceDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Custom ${state.viceEmoji} Entry'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter amount...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                state.addDrink(val);
              }
              Navigator.pop(context);
            },
            child: const Text('LOG'),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final AppState state;
  const _ActivityRow({required this.state});

  @override
  Widget build(BuildContext context) {
    // Current difficulty multiplier
    final diff = state.currentDifficulty;

    // Calculate reward values for standard sessions
    // Run 5k @ (0.5 pts/km * diff)
    final runVal = (5.0 * 0.5 * diff);
    // Cycle 15k @ (1/6 pts/km * diff) -> (0.166... * 15 = 2.5 * diff)
    final cycleVal = (15.0 * (1.0 / 6.0) * diff);
    // Swim 30l @ (1/60 pts/length * diff) -> (0.5 * diff)
    final swimVal = (30.0 * (1.0 / 60.0) * diff);

    String format(double val) =>
        '+${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)}';

    return Row(
      children: [
        _ActivityButton(
          icon: Icons.directions_run,
          value: format(runVal),
          onTap: () => state.addActivity('Run', 5.0),
          color: Colors.orange,
        ),
        const SizedBox(width: 4),
        _ActivityButton(
          icon: Icons.directions_bike,
          value: format(cycleVal),
          onTap: () => state.addActivity('Cycle', 15.0),
          color: Colors.blue,
        ),
        const SizedBox(width: 4),
        _ActivityButton(
          icon: Icons.pool,
          value: format(swimVal),
          onTap: () => state.addActivity('Swim', 30.0),
          color: Colors.cyan,
        ),
      ],
    );
  }
}

class _ActivityButton extends StatelessWidget {
  final IconData icon;
  final String value;
  final VoidCallback onTap;
  final Color color;

  const _ActivityButton({
    required this.icon,
    required this.value,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              Positioned(
                top: 4,
                right: 4,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
