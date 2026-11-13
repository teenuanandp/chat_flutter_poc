
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat_flutter_poc/core/theme/theme_controller.dart';
import 'package:chat_flutter_poc/core/theme/app_theme.dart';
import 'package:chat_flutter_poc/features/authentication/presentation/screens/welcome_screen.dart';
import 'package:chat_flutter_poc/features/authentication/presentation/screens/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for theme preference changes.
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',

      // Light and dark theme configurations.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // System, Light, or Dark.
      themeMode: themeController.themeMode,

      routes: {
        // '/login': (context) => const LoginScreen(),
        // '/register': (context) => const RegisterScreen(),
      },

      home: const WelcomeScreen(),
    );
  }
}
