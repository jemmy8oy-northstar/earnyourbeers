import 'package:flutter/material.dart';
import 'ui/theme.dart';
import 'ui/screens/dashboard_screen.dart';

void main() {
  runApp(const EarnYourBeersApp());
}

class EarnYourBeersApp extends StatelessWidget {
  const EarnYourBeersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Earn Your Beers',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
