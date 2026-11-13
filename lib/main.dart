import 'package:flutter/material.dart';
import 'app/app.dart';

// DI
import 'package:chat_flutter_poc/core/di/injection_container.dart';
// Theam 
import 'package:provider/provider.dart';

import 'core/theme/theme_controller.dart';
import 'core/theme/theme_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController(
    ThemeStorage(),
  );

  await setupDependencies();

  await themeController.loadPreferences();

  runApp(
    ChangeNotifierProvider.value(
      value: themeController,
      child: const MyApp(),
    ),
  );
}