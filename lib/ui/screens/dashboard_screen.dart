import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/logic/app_state.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<AppState>().balance;

    return Scaffold(
      appBar: AppBar(title: const Text('Earn Your Beers 🍻')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }
}
