import 'package:chat_flutter_poc/core/di/injection_container.dart';
import 'package:chat_flutter_poc/features/authentication/presentation/cubit/login_cubit.dart';
import 'package:chat_flutter_poc/features/authentication/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:chat_flutter_poc/core/shared/widgets/buttons/app_button.dart';
import 'package:chat_flutter_poc/core/shared/widgets/feedback/app_snackbar.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        Icons.forum_rounded,
                        size: 58,
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Welcome Heading
                    Text(
                      'Connect. Chat. Share.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Stay connected with your friends and family. '
                      'Share moments, exchange messages and enjoy '
                      'conversations that matter.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Get Started Button
                    AppButton(
                      text: 'Get Started',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        AppSnackBar.show(
                          context,
                          message: 'Create screen is coming next!',
                          type: SnackBarType.info,
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Existing User Login
                    AppButton(
                      text: 'I already have an account',
                      type: AppButtonType.outlined,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (_) => getIt<LoginCubit>(),
                              child: const LoginScreen(),
                            ),
                          ),
                        );
                        },
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Simple conversations. Meaningful connections.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
