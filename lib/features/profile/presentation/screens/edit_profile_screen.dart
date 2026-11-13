
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chat_flutter_poc/core/di/injection_container.dart';
import 'package:chat_flutter_poc/core/shared/widgets/avatar/app_avatar.dart';
import 'package:chat_flutter_poc/core/shared/widgets/inputs/app_text_field.dart';
import 'package:chat_flutter_poc/core/shared/widgets/buttons/app_button.dart';
import 'package:chat_flutter_poc/core/shared/widgets/feedback/app_snackbar.dart';

import '../../../authentication/data/models/auth_user_model.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final AuthUserModel profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _aboutController;

  late final EditProfileCubit _cubit;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.profile.displayName,
    );

    _aboutController = TextEditingController(
      text: widget.profile.about ?? '',
    );

    _cubit = EditProfileCubit(
      updateProfileUseCase: getIt(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _cubit.close();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final updatedProfile = await _cubit.updateProfile(
      displayName: _nameController.text.trim(),
      about: _aboutController.text.trim(),
    );

    if (!mounted) return;

    if (updatedProfile != null) {
      AppSnackBar.show(
        context,
        message: 'Profile updated successfully.',
      );

      Navigator.of(context).pop(updatedProfile);
    } else {
      AppSnackBar.show(
        context,
        message: _cubit.state.errorMessage ??
            'Unable to update profile.',
      );
    }
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : 'Not available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit profile'),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile image
                  Center(
                    child: Column(
                      children: [
                        AppAvatar(
                          displayName: widget.profile.displayName,
                          size: 112,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Profile picture',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Personal information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Manage your personal information below.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Editable display name
                  AppTextField(
                    controller: _nameController,
                    label: 'Display name',
                    hint: 'Enter your display name',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Display name is required';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Read-only username
                  _buildReadOnlyField(
                    label: 'Username',
                    value: widget.profile.userName,
                    icon: Icons.alternate_email,
                  ),

                  const SizedBox(height: 24),

                  // Read-only email
                  _buildReadOnlyField(
                    label: 'Email address',
                    value: widget.profile.email,
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 24),

                  // Editable about
                  AppTextField(
                    controller: _aboutController,
                    label: 'About',
                    hint: 'Tell something about yourself',
                    type: AppTextFieldType.multiline,
                    minLines: 4,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  BlocBuilder<EditProfileCubit, EditProfileState>(
                    builder: (context, state) {
                      return AppButton(
                        onPressed: state.isLoading
                            ? null
                            : _saveProfile,
                        text: state.isLoading
                            ? 'Saving...'
                            : 'Save changes',
                        icon: Icons.check,
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
