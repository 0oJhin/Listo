import 'package:flutter/material.dart';

import 'core/app_colors.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ListoApp());
}

class ListoApp extends StatefulWidget {
  const ListoApp({super.key});

  static ListoAppState of(BuildContext context) {
    return context.findAncestorStateOfType<ListoAppState>()!;
  }

  @override
  State<ListoApp> createState() => ListoAppState();
}

class ListoAppState extends State<ListoApp> {
  ThemeMode _themeMode = ThemeMode.light;

  bool get darkModeEnabled => _themeMode == ThemeMode.dark;

  void setDarkMode(bool enabled) {
    setState(() {
      _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listo',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF171A14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
