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
          const SizedBox(height: 60),
          Text(
            balance.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBeer,
            ),
          ),
          const Text(
            'PINTS AVAILABLE',
            style: TextStyle(
              fontSize: 18,
              letterSpacing: 2,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 40),
          const Divider(indent: 32, endIndent: 32),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'RECENT ACTIVITY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white24,
              ),
            ),
          ),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, state, child) {
                final logs = state.logs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final item = logs[index];
                    final isActivity = item is Activity;
                    final amount = isActivity
                        ? item.amount
                        : (item as Drink).amount;
                    final id = isActivity ? item.id : (item as Drink).id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: Icon(
                        isActivity ? Icons.directions_run : Icons.sports_bar,
                        color: isActivity
                            ? AppTheme.primaryBeer
                            : AppTheme.deepAmber,
                      ),
                      title: Text(
                        isActivity
                            ? '${amount.toStringAsFixed(1)} km Run'
                            : '${amount.toInt()} Pint Drink',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 10,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
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
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () {
                              if (isActivity) {
                                state.updateActivity(item, amount + 0.5);
                              } else {
                                state.updateDrink(item as Drink, amount + 1);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.white24,
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => context.read<AppState>().addActivity(5.0),
            label: const Text('Log Run (5k)'),
            icon: const Icon(Icons.directions_run),
            backgroundColor: AppTheme.primaryBeer,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () => context.read<AppState>().addDrink(1.0),
            label: const Text('Log Pint'),
            icon: const Icon(Icons.sports_bar),
            backgroundColor: AppTheme.deepAmber,
          ),
        ],
      ),
    );
  }
}
