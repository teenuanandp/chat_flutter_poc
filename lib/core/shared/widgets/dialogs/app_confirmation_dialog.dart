
import 'package:flutter/material.dart';
import 'package:chat_flutter_poc/core/theme/app_colors.dart';

/// Result returned by the confirmation dialog.
class AppConfirmationResult {
  final bool confirmed;
  final bool optionChecked;

  const AppConfirmationResult({
    required this.confirmed,
    this.optionChecked = false,
  });
}

class AppConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  final String? checkboxLabel;
  final bool initialCheckboxValue;
  final bool isDestructive;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.checkboxLabel,
    this.initialCheckboxValue = false,
    this.isDestructive = false,
  });

  @override
  State<AppConfirmationDialog> createState() =>
      _AppConfirmationDialogState();
}

class _AppConfirmationDialogState
    extends State<AppConfirmationDialog> {
  late bool _optionChecked;

  @override
  void initState() {
    super.initState();
    _optionChecked = widget.initialCheckboxValue;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? AppColors.darkSurface : AppColors.surface;

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.primary;

    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final destructiveColor =
        isDark ? AppColors.darkError : AppColors.error;

    return AlertDialog(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusXl),
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: TextStyle(
              color: secondaryTextColor,
              height: 1.5,
            ),
          ),

          if (widget.checkboxLabel != null) ...[
            const SizedBox(height: 20),

            InkWell(
              onTap: () {
                setState(() {
                  _optionChecked = !_optionChecked;
                });
              },
              borderRadius: BorderRadius.circular(AppColors.radiusSm),
              child: Row(
                children: [
                  Checkbox(
                    value: _optionChecked,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _optionChecked = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.checkboxLabel!,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text(
            widget.cancelText,
            style: TextStyle(color: secondaryTextColor),
          ),
        ),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor:
                widget.isDestructive ? destructiveColor : primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
            ),
          ),
          onPressed: () {
            Navigator.pop(
              context,
              AppConfirmationResult(
                confirmed: true,
                optionChecked: _optionChecked,
              ),
            );
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}

/// Helper function to show the dialog from anywhere in the app.
Future<AppConfirmationResult?> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  String? checkboxLabel,
  bool initialCheckboxValue = false,
  bool isDestructive = false,
}) {
  return showDialog<AppConfirmationResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AppConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      checkboxLabel: checkboxLabel,
      initialCheckboxValue: initialCheckboxValue,
      isDestructive: isDestructive,
    ),
  );
}
