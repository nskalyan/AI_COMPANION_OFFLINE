import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_shell.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init storage (Hive) before any widget can access it
  await StorageService.init();
  // Init notifications (local + scheduled)
  await NotificationService.init();

  runApp(const CompanionApp());
}

class CompanionApp extends StatefulWidget {
  const CompanionApp({super.key});

  @override
  State<CompanionApp> createState() => _CompanionAppState();
}

class _CompanionAppState extends State<CompanionApp> {
  bool _ready = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // Persistent dark/light theme
    final dark = await StorageService.loadThemeMode();
    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });

    // App is ready after prefs loaded
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E6AE6),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E6AE6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: _ready
          ? const HomeShell()
          : SplashScreen(onReady: () => setState(() => _ready = true)),
    );
  }
}
