import 'package:flutter/material.dart';

import 'package:chat_flutter_poc/core/theme/app_colors.dart';

enum AppButtonType {
  primary,
  secondary,
  outlined,
  gradient,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    // Select theme colours.
    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.primary;

    final primaryForeground = isDark
        ? AppColors.darkPrimaryForeground
        : AppColors.primaryForeground;

    final secondary = isDark
        ? AppColors.darkSecondary
        : AppColors.secondary;

    final secondaryForeground = isDark
        ? AppColors.darkSecondaryForeground
        : AppColors.secondaryForeground;

    // Select button background.
    final backgroundColor = switch (type) {
      AppButtonType.primary => primary,
      AppButtonType.secondary => secondary,
      AppButtonType.outlined => Colors.transparent,
      AppButtonType.gradient => Colors.transparent,
    };

    // Select button text and icon colour.
    final foregroundColor = switch (type) {
      AppButtonType.primary => primaryForeground,
      AppButtonType.secondary => secondaryForeground,
      AppButtonType.outlined => primary,
      AppButtonType.gradient => primaryForeground,
    };

    // Select gradient based on current theme.
    final gradient = isDark
        ? AppColors.darkBrandGradient
        : AppColors.brandGradient;

    final radius = BorderRadius.circular(AppColors.radiusMd);

    // Button styling.
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: backgroundColor,
      disabledForegroundColor: foregroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      minimumSize: Size(double.infinity, height),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: type == AppButtonType.outlined
            ? BorderSide(color: primary)
            : BorderSide.none,
      ),
    );

    // Button content.
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foregroundColor,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );

    // Gradient buttons need a decorated background.
    if (type == AppButtonType.gradient) {
      return ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          child: button,
        ),
      );
    }

    return button;
  }
}
