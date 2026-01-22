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
      difficultyMultiplier: state.currentDifficulty,
    );

    // 4. Handle List Sync using addPostFrameCallback to avoid build-time side effects
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncHistoryList(weeklyLogs);
      }
    });

    final isCurrentWeek = widget.weekOffset == 0;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          '${balance.toStringAsFixed(2)} ${state.viceEmoji}',
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
        if (isCurrentWeek) ...[
          const SizedBox(height: 12),
          _ActionRow(state: state),
        ],
        const SizedBox(height: 8),

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
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          top: 16,
                          bottom: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'LOG HISTORY',
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
                          initialItemCount: weeklyLogs.length,
                          itemBuilder: (context, index, animation) {
                            if (index >= weeklyLogs.length) {
                              return const SizedBox.shrink();
                            }
                            return _buildHistoryTile(
                              weeklyLogs[index],
                              animation,
                              isCurrentWeek && index == 0,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  void _syncHistoryList(List<dynamic> currentWeeklyLogs) {
    // Sync logic for the full list now
    for (int i = 0; i < currentWeeklyLogs.length; i++) {
      final item = currentWeeklyLogs[i];
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
    _previousHistory = List.from(currentWeeklyLogs);
  }

  void _deleteItem(BuildContext context, dynamic item) {
    final id = item is Activity ? item.id : (item as Drink).id;
    if (item is Activity) {
      context.read<AppState>().deleteActivity(id);
    } else {
      context.read<AppState>().deleteDrink(id);
    }
  }

  Widget _buildHistoryTile(
    dynamic item,
    Animation<double> animation,
    bool isMostRecent,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: animation,
        child: _HistoryTile(
          item: item,
          onDelete: () => _deleteItem(context, item),
          onEdit: () => _showEditDialog(context, item),
          showActions: isMostRecent,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic item) {
    final isActivity = item is Activity;
    final type = isActivity ? item.type : 'Amount';
    final state = context.read<AppState>();
    final unit = isActivity
        ? (type == 'Swim' ? 'lengths' : 'km')
        : state.viceEmoji;

    final controller = TextEditingController(
      text: item.amount % 1 == 0
          ? item.amount.toInt().toString()
          : item.amount.toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActivity ? 'Edit $type ($unit)' : 'Edit $unit'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter amount...',
            suffixText: isActivity ? unit : '',
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
                  state.updateActivity(item, val);
                } else {
                  state.updateDrink(item as Drink, val);
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

/// History tile - always displayed as a compact tile
class _HistoryTile extends StatelessWidget {
  final dynamic item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool showActions;

  const _HistoryTile({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
    this.showActions = false,
  });

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
      subtitle: Text(
        'Logged at ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.24),
          fontSize: 10,
        ),
      ),
      trailing: showActions
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(icon: Icons.edit_outlined, onPressed: onEdit),
                const SizedBox(width: 4),
                _ActionButton(icon: Icons.delete_outline, onPressed: onDelete),
              ],
            )
          : null,
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
    // Calculate weekly totals for display
    final now = state.simulatedNow;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final weeklyActivities = state.activities.where(
      (a) => a.timestamp.isAfter(startOfWeek),
    );

    final runTotal = weeklyActivities
        .where((a) => a.type == 'Run')
        .fold<double>(0, (sum, a) => sum + a.amount);
    final cycleTotal = weeklyActivities
        .where((a) => a.type == 'Cycle')
        .fold<double>(0, (sum, a) => sum + a.amount);
    final swimTotal = weeklyActivities
        .where((a) => a.type == 'Swim')
        .fold<double>(0, (sum, a) => sum + a.amount);

    final drinkTotal = state.drinks
        .where((d) => d.timestamp.isAfter(startOfWeek))
        .fold<double>(0, (sum, d) => sum + d.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: _ViceActionCard(state: state, currentTotal: drinkTotal),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _ActivityGrid(
                state: state,
                runTotal: runTotal,
                cycleTotal: cycleTotal,
                swimTotal: swimTotal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViceActionCard extends StatelessWidget {
  final AppState state;
  final double currentTotal;
  const _ViceActionCard({required this.state, required this.currentTotal});

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.viceEmoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(
                '+1 ${state.viceEmoji}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${currentTotal.toInt()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'TOTAL',
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

class _ActivityGrid extends StatelessWidget {
  final AppState state;
  final double runTotal;
  final double cycleTotal;
  final double swimTotal;

  const _ActivityGrid({
    required this.state,
    required this.runTotal,
    required this.cycleTotal,
    required this.swimTotal,
  });

  @override
  Widget build(BuildContext context) {
    final diff = state.currentDifficulty;
    final runVal = (1.0 * 0.5 * diff);
    final cycleVal = (1.0 * (1.0 / 6.0) * diff);
    final swimVal = (1.0 * (1.0 / 60.0) * diff);

    String formatVal(double val) =>
        '+${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(2)}';

    return Column(
      children: [
        Row(
          children: [
            _ActivityButton(
              icon: Icons.directions_run,
              increment: '+1km',
              total: runTotal,
              value: formatVal(runVal),
              onTap: () => state.addActivity('Run', 1.0),
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            _ActivityButton(
              icon: Icons.directions_bike,
              increment: '+1km',
              total: cycleTotal,
              value: formatVal(cycleVal),
              onTap: () => state.addActivity('Cycle', 1.0),
              color: Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ActivityButton(
              icon: Icons.pool,
              increment: '+1 len',
              total: swimTotal,
              value: formatVal(swimVal),
              onTap: () => state.addActivity('Swim', 1.0),
              color: Colors.cyan,
            ),
            const SizedBox(width: 8),
            _ActivityButton(
              icon: Icons.more_horiz,
              increment: 'Coming',
              total: 0,
              value: 'Soon',
              onTap: () {},
              color: Colors.grey,
              isEnabled: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityButton extends StatelessWidget {
  final IconData icon;
  final String increment;
  final double total;
  final String value;
  final VoidCallback onTap;
  final Color color;
  final bool isEnabled;

  const _ActivityButton({
    required this.icon,
    required this.increment,
    required this.total,
    required this.value,
    required this.onTap,
    required this.color,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 20),
                      Text(
                        increment,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: color.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        total > 0
                            ? '${total % 1 == 0 ? total.toInt() : total.toStringAsFixed(1)}'
                            : '-',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
