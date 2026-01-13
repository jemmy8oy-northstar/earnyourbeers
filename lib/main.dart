import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/theme.dart';
import 'ui/screens/dashboard_screen.dart';
import 'core/services/isar_service.dart';
import 'core/logic/app_state.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<IsarService>(create: (_) => IsarService()),
        ChangeNotifierProxyProvider<IsarService, AppState>(
          create: (context) => AppState(context.read<IsarService>()),
          update: (context, isarService, appState) =>
              appState ?? AppState(isarService),
        ),
      ],
      child: const EarnYourBeersApp(),
    ),
  );
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
