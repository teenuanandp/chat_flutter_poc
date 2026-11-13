import 'package:chat_flutter_poc/features/authentication/presentation/cubit/login_cubit.dart';
import 'package:chat_flutter_poc/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chat_flutter_poc/core/shared/widgets/buttons/app_button.dart';
import 'package:chat_flutter_poc/core/shared/widgets/inputs/app_text_field.dart';
import 'package:chat_flutter_poc/core/shared/widgets/feedback/app_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Access the form and trigger validation.
  final _formKey = GlobalKey<FormState>();

  // Controllers for reading user input.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Validate email format.
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your username or email';
    }

    return null;
  }

  // Validate password.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  // Handle login button.
  void _handleLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<LoginCubit>().login(
      userNameOrEmail: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success && state.user != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                displayName: state.user!.displayName,
                email: state.user!.email,
              ),
            ),
            (route) => false,
          );
        }

        if (state.status == LoginStatus.failure) {
          AppSnackBar.show(
            context,
            message: state.message ?? 'Login failed',
            type: SnackBarType.error,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App logo
                      Center(
                        child: Container(
                          height: 76,
                          width: 76,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.chat_bubble_rounded,
                            size: 38,
                            color: colors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Heading
                      Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Sign in to continue your conversations.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Email field
                      AppTextField(
                        label: 'User name or email',
                        hint: 'Enter your user name or email',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 20),

                      // Password field
                      AppTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        type: AppTextFieldType.password,
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        onSubmitted: (_) => _handleLogin(),
                      ),

                      const SizedBox(height: 12),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            AppSnackBar.show(
                              context,
                              message:
                                  'Forgot password will be implemented later.',
                              type: SnackBarType.info,
                            );
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login button
                      AppButton(text: 'Login', onPressed: _handleLogin),

                      const SizedBox(height: 28),

                      // Registration navigation placeholder
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              AppSnackBar.show(
                                context,
                                message: 'Registration screen coming soon.',
                                type: SnackBarType.info,
                              );
                            },
                            child: const Text('Create Account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
