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
                    return ListTile(
                      leading: Icon(
                        isActivity ? Icons.directions_run : Icons.sports_bar,
                        color: isActivity
                            ? AppTheme.primaryBeer
                            : AppTheme.deepAmber,
                      ),
                      title: Text(
                        isActivity
                            ? '${item.amount} km Run'
                            : '${item.amount} Pint Drink',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white24),
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
            onPressed: () => _showLogDialog(context, 'Run', 'Enter KM'),
            label: const Text('Log Run'),
            icon: const Icon(Icons.directions_run),
            backgroundColor: AppTheme.primaryBeer,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () => _showLogDialog(context, 'Drink', 'Enter Pints'),
            label: const Text('Log Drink'),
            icon: const Icon(Icons.sports_bar),
            backgroundColor: AppTheme.deepAmber,
          ),
        ],
      ),
    );
  }

  void _showLogDialog(BuildContext context, String type, String hint) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log $type'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 0.0;
              if (value > 0) {
                final state = Provider.of<AppState>(context, listen: false);
                if (type == 'Run') {
                  state.addActivity(value);
                } else {
                  state.addDrink(value);
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
