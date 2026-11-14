import 'package:chat_flutter_poc/features/chat/presentation/cubit/chat_messages_cubit.dart';
import 'package:chat_flutter_poc/features/chat_list/presentation/widgets/chat_list_shimmer.dart';
import 'package:chat_flutter_poc/features/profile/data/storage/profile_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart'; // Adjust path if needed
import '../cubit/conversation_cubit.dart';
import '../cubit/conversation_state.dart';
import '../widgets/conversation_tile.dart';
import '../../../chat/presentation/screens/chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConversationCubit>()..loadConversations(),
      child: const _ChatScreenContent(),
    );
  }
}

class _ChatScreenContent extends StatelessWidget {
  const _ChatScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.background;

    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<ConversationCubit, ConversationState>(
        builder: (context, state) {
          // Loading
          if (state is ConversationLoading) {
            return const ChatListShimmer();
          }

          // Error
          if (state is ConversationError) {
            return _ErrorView(
              message: state.message,
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onRetry: () {
                context.read<ConversationCubit>().loadConversations();
              },
            );
          }

          // Empty
          if (state is ConversationEmpty) {
            return RefreshIndicator(
              color: primaryColor,
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.surface,
              onRefresh: () {
                return context.read<ConversationCubit>().loadConversations();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 150),
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'No conversations yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Your conversations will appear here',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Loaded
          if (state is ConversationLoaded) {
            return RefreshIndicator(
              color: primaryColor,
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.surface,
              onRefresh: () {
                return context.read<ConversationCubit>().loadConversations();
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.conversations.length,
                separatorBuilder: (_, __) {
                  return Divider(
                    height: 1,
                    indent: 80,
                    color: borderColor.withValues(alpha: 0.65),
                  );
                },
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];

                  return ConversationTile(
                    conversation: conversation,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => getIt<ChatMessagesCubit>(),
                            child: ChatDetailScreen(
                              conversation: conversation,
                              profileLocalStorage: getIt<ProfileLocalStorage>(),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// Error View
class _ErrorView extends StatelessWidget {
  final String message;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppColors.radius2xl),
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 42,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusFull),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
