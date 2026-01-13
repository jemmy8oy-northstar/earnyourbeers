import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/logic/app_state.dart';
import '../../core/models/activity.dart';
import '../../core/models/drink.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<AppState>().balance;

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
            child: Consumer<AppState>(
              builder: (context, state, child) {
                final logs = state.logs;
                if (logs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No activity yet. Get moving! 🍻',
                      style: TextStyle(color: Colors.white24),
                    ),
                  );
                }

                // Grouping logic
                final Map<String, List<dynamic>> grouped = {};
                for (var log in logs) {
                  final date = log.timestamp;
                  final today = DateTime.now();
                  final yesterday = today.subtract(const Duration(days: 1));

                  String header;
                  if (date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day) {
                    header = 'TODAY';
                  } else if (date.year == yesterday.year &&
                      date.month == yesterday.month &&
                      date.day == yesterday.day) {
                    header = 'YESTERDAY';
                  } else {
                    header = '${date.day}/${date.month}/${date.year}';
                  }

                  if (!grouped.containsKey(header)) grouped[header] = [];
                  grouped[header]!.add(log);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, groupIndex) {
                    final header = grouped.keys.elementAt(groupIndex);
                    final items = grouped[header]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            top: 16,
                            bottom: 8,
                          ),
                          child: Text(
                            header,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.white24,
                            ),
                          ),
                        ),
                        ...items.map((item) {
                          final isTop = item == logs[0];
                          return _LogItem(
                            key: ValueKey(
                              item is Activity ? item.id : (item as Drink).id,
                            ),
                            item: item,
                            isMostRecent: isTop,
                            onEdit: () => _showEditDialog(context, item),
                          );
                        }),
                      ],
                    );
                  },
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
            onPressed: () => context.read<AppState>().addDrink(1.0),
            label: const Text('Log Pint'),
            icon: const Icon(Icons.sports_bar),
            backgroundColor: AppTheme.primaryBeer,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () => context.read<AppState>().addActivity(5.0),
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
                  // Round to 1 decimal for drinks
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

class _LogItem extends StatefulWidget {
  final dynamic item;
  final bool isMostRecent;
  final VoidCallback onEdit;

  const _LogItem({
    super.key,
    required this.item,
    required this.isMostRecent,
    required this.onEdit,
  });

  @override
  State<_LogItem> createState() => _LogItemState();
}

class _LogItemState extends State<_LogItem> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Delay setting visible to trigger entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isActivity = widget.item is Activity;
    final amount = isActivity
        ? widget.item.amount
        : (widget.item as Drink).amount;
    final id = isActivity ? widget.item.id : (widget.item as Drink).id;
    final state = context.read<AppState>();

    final label = isActivity
        ? '${amount.toStringAsFixed(1)} km Run'
        : '${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(1)} Pint${amount == 1 ? '' : 's'}';

    final activeCard = Card(
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
                        'Logged at ${widget.item.timestamp.hour}:${widget.item.timestamp.minute.toString().padLeft(2, '0')}',
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
                        state.updateActivity(widget.item, amount - 0.5);
                    } else {
                      if (amount > 1)
                        state.updateDrink(widget.item as Drink, amount - 1);
                    }
                  },
                ),
                _ActionButton(
                  icon: Icons.add,
                  onPressed: () {
                    if (isActivity) {
                      state.updateActivity(widget.item, amount + 0.5);
                    } else {
                      state.updateDrink(widget.item as Drink, amount + 1);
                    }
                  },
                ),
                _ActionButton(icon: Icons.edit, onPressed: widget.onEdit),
                _ActionButton(
                  icon: Icons.delete_outline,
                  onPressed: () {
                    if (isActivity) {
                      state.deleteActivity(id);
                    } else {
                      state.deleteDrink(id);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final historyTile = ListTile(
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
      trailing: Text(
        '${widget.item.timestamp.hour}:${widget.item.timestamp.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(color: Colors.white24, fontSize: 12),
      ),
    );

    // Simplified entrance bloom
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedScale(
        scale: _isVisible ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: AnimatedCrossFade(
            firstChild: activeCard,
            secondChild: historyTile,
            crossFadeState: widget.isMostRecent
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 500),
            sizeCurve: Curves.easeInOut,
            firstCurve: Curves.easeIn,
            secondCurve: Curves.easeOut,
          ),
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
