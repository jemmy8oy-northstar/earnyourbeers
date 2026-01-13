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
                          final isActivity = item is Activity;
                          final amount = isActivity
                              ? item.amount
                              : (item as Drink).amount;
                          final id = isActivity ? item.id : (item as Drink).id;
                          final label = isActivity
                              ? '${amount.toStringAsFixed(1)} km Run'
                              : '${amount.toInt()} Pint${amount.toInt() == 1 ? '' : 's'}';

                          final isMostRecent = item == logs[0];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            leading: Icon(
                              isActivity
                                  ? Icons.directions_run
                                  : Icons.sports_bar,
                              color: isActivity
                                  ? AppTheme.primaryBeer
                                  : AppTheme.deepAmber,
                              size: 20,
                            ),
                            title: Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Colors.white24,
                                fontSize: 10,
                              ),
                            ),
                            trailing: isMostRecent
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _ActionButton(
                                        icon: Icons.remove,
                                        onPressed: () {
                                          if (isActivity) {
                                            if (amount > 0.5)
                                              state.updateActivity(
                                                item,
                                                amount - 0.5,
                                              );
                                          } else {
                                            if (amount > 1)
                                              state.updateDrink(
                                                item as Drink,
                                                amount - 1,
                                              );
                                          }
                                        },
                                      ),
                                      _ActionButton(
                                        icon: Icons.add,
                                        onPressed: () {
                                          if (isActivity) {
                                            state.updateActivity(
                                              item,
                                              amount + 0.5,
                                            );
                                          } else {
                                            state.updateDrink(
                                              item as Drink,
                                              amount + 1,
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 16,
                                          color: Colors.white10,
                                        ),
                                        onPressed: () {
                                          if (isActivity) {
                                            state.deleteActivity(id);
                                          } else {
                                            state.deleteDrink(id);
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                : null,
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
