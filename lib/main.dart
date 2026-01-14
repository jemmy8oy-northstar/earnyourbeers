import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/theme.dart';
import 'ui/screens/dashboard_screen.dart';
import 'core/services/database.dart';
import 'core/logic/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider(create: (context) => AppState(database)),
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
