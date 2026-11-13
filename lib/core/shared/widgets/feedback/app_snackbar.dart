
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
  }) {
    final color = switch (type) {
      SnackBarType.success => AppColors.success,
      SnackBarType.error => AppColors.error,
      SnackBarType.warning => AppColors.warning,
      SnackBarType.info => AppColors.info,
    };

    final icon = switch (type) {
      SnackBarType.success => Icons.check_circle,
      SnackBarType.error => Icons.error,
      SnackBarType.warning => Icons.warning,
      SnackBarType.info => Icons.info,
    };

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
