
import 'package:flutter/material.dart';

import 'package:chat_flutter_poc/core/theme/app_colors.dart';

enum AppTextFieldType {
  text,
  password,
  multiline,
}

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final AppTextFieldType type;

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final IconData? prefixIcon;
  final Widget? suffixIcon;

  final int minLines;
  final int maxLines;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final bool enabled;
  final bool readOnly;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.type = AppTextFieldType.text,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.minLines = 1,
    this.maxLines = 5,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
  }) : assert(minLines >= 1),
       assert(maxLines >= minLines);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  bool get _isPassword =>
      widget.type == AppTextFieldType.password;

  bool get _isMultiline =>
      widget.type == AppTextFieldType.multiline;

  @override
  Widget build(BuildContext context) {
    // Detect current application theme.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Select design tokens.
    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.primary;

    final background = isDark
        ? AppColors.darkInput
        : AppColors.input;

    final border = isDark
        ? AppColors.darkBorder
        : AppColors.border;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    final mutedColor = isDark
        ? AppColors.darkMutedForeground
        : AppColors.mutedForeground;

    final errorColor = isDark
        ? AppColors.darkError
        : AppColors.error;

    final radius = BorderRadius.circular(AppColors.radiusMd);

    // Reusable border configuration.
    OutlineInputBorder buildBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
      );
    }

    return TextFormField(
      controller: widget.controller,

      // Password visibility.
      obscureText: _isPassword && _obscureText,

      // Multiline configuration.
      minLines: _isMultiline ? widget.minLines : 1,
      maxLines: _isMultiline ? widget.maxLines : 1,

      // Keyboard configuration.
      keyboardType: widget.keyboardType ??
          (_isMultiline
              ? TextInputType.multiline
              : _isPassword
                  ? TextInputType.visiblePassword
                  : TextInputType.text),

      textInputAction: widget.textInputAction ??
          (_isMultiline
              ? TextInputAction.newline
              : TextInputAction.next),

      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,

      enabled: widget.enabled,
      readOnly: widget.readOnly,

      textAlignVertical: _isMultiline
          ? TextAlignVertical.top
          : TextAlignVertical.center,

      style: TextStyle(
        color: textColor,
        fontSize: 14,
      ),

      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,

        labelStyle: TextStyle(color: mutedColor),
        hintStyle: TextStyle(color: mutedColor),

        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon)
            : null,

        prefixIconColor: mutedColor,
        suffixIconColor: mutedColor,

        suffixIcon: _isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              )
            : widget.suffixIcon,

        filled: true,
        fillColor: background,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: buildBorder(border),
        enabledBorder: buildBorder(border),
        disabledBorder: buildBorder(border),

        focusedBorder: buildBorder(primary, width: 1.5),

        errorBorder: buildBorder(errorColor),

        focusedErrorBorder: buildBorder(
          errorColor,
          width: 1.5,
        ),
      ),
    );
  }
}
