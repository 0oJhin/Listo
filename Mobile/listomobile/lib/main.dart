import 'package:flutter/material.dart';

import 'core/app_colors.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const ListoApp());
}

class ListoApp extends StatelessWidget {
  const ListoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
