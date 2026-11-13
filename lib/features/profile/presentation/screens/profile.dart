import 'package:chat_flutter_poc/core/di/injection_container.dart';
import 'package:chat_flutter_poc/core/shared/widgets/avatar/app_avatar.dart';
import 'package:chat_flutter_poc/core/shared/widgets/buttons/app_button.dart';
import 'package:chat_flutter_poc/core/shared/widgets/feedback/app_snackbar.dart';
import 'package:chat_flutter_poc/core/theme/theme_controller.dart';
import 'package:chat_flutter_poc/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:flutter/material.dart';

import 'package:chat_flutter_poc/core/shared/widgets/feedback/app_shimmer.dart';
import 'package:chat_flutter_poc/core/theme/app_colors.dart';
import 'package:chat_flutter_poc/core/shared/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/storage/profile_local_storage.dart';

class ProfileScreen extends StatefulWidget {
  final String displayName;
  final String email;

  const ProfileScreen({
    super.key,
    required this.displayName,
    required this.email,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileLocalStorage _localStorage = ProfileLocalStorage();

  String _displayName = '';
  String _userName = '';
  String _email = '';
  String _about = '';
  String _status = '';
  String _createdAtUtc = '';
  String? _profilePhotoFileId;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalProfile();
  }

  Future<void> _showLogoutConfirmation() async {
    final result = await showAppConfirmationDialog(
      context: context,
      title: 'Confirm logout',
      message: 'Are you sure you want to log out of your account?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      checkboxLabel: 'Log out from all devices',
      initialCheckboxValue: false,
      isDestructive: true,
    );

    if (!mounted) return;

    // User cancelled the dialog.
    if (result == null || !result.confirmed) return;

    await _handleLogout(logoutFromAllDevices: result.optionChecked);
  }

  Future<void> _handleLogout({required bool logoutFromAllDevices}) async {
    try {
      await getIt<AuthRemoteDataSource>().logout(
        logoutFromAllDevices: logoutFromAllDevices,
      );

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Unable to logout. Please try again.');
    }
  }

  Future<void> _loadLocalProfile() async {
    try {
      final profile = await _localStorage.getProfile();

      if (!mounted) return;

      setState(() {
        _displayName = profile?.displayName.isNotEmpty == true
            ? profile!.displayName
            : widget.displayName;

        _userName = profile?.userName ?? '';
        _email = profile?.email.isNotEmpty == true
            ? profile!.email
            : widget.email;

        _about = profile?.about ?? '';
        _status = profile?.status ?? '';
        _profilePhotoFileId = profile?.profilePhotoFileId;
        _createdAtUtc = profile?.createdAtUtc != null
            ? _formatDate(profile!.createdAtUtc!)
            : '';

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _displayName = widget.displayName;
        _email = widget.email;
        _isLoading = false;
      });
    }
  }

  void _toggleTheme() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    context.read<ThemeController>().setThemeMode(
      isDarkMode ? ThemeMode.light : ThemeMode.dark,
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: theme.brightness == Brightness.dark
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            onPressed: _toggleTheme,
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Profile header
              Center(
                child: Column(
                  children: [
                    _buildProfileAvatar(),

                    const SizedBox(height: 20),

                    if (_isLoading)
                      const AppShimmerBox(
                        width: 180,
                        height: 22,
                        radius: AppColors.radiusSm,
                      )
                    else
                      Text(
                        _displayName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 6),

                    if (_isLoading)
                      const AppShimmerBox(
                        width: 140,
                        height: 16,
                        radius: AppColors.radiusSm,
                      )
                    else
                      Text(
                        _userName.isNotEmpty ? '@$_userName' : '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // About section
              if (_isLoading || _about.isNotEmpty) ...[
                _buildSectionTitle('About'),
                const SizedBox(height: 12),
                _isLoading
                    ? const AppShimmerBox(
                        width: double.infinity,
                        height: 65,
                        radius: AppColors.radiusLg,
                      )
                    : _buildAboutCard(),
                const SizedBox(height: 28),
              ],

              // Account information
              _buildSectionTitle('Account information'),
              const SizedBox(height: 16),

              _buildInfoTile(
                icon: Icons.person_outline,
                label: 'Display name',
                value: _displayName,
              ),

              _buildInfoTile(
                icon: Icons.alternate_email,
                label: 'Username',
                value: _userName,
              ),

              _buildInfoTile(
                icon: Icons.email_outlined,
                label: 'Email address',
                value: _email,
              ),

              _buildInfoTile(
                icon: Icons.calendar_today_outlined,
                label: 'Joined on',
                value: _createdAtUtc,
              ),
              const SizedBox(height: 24),

              AppButton(
                onPressed: _showLogoutConfirmation,
                text: "Logout",
                icon: Icons.logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final name = _displayName.trim().isNotEmpty
        ? _displayName
        : widget.displayName;

    return AppAvatar(displayName: name, size: 112);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAboutCard() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Text(_about, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not available' : value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
