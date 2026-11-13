
import 'package:chat_flutter_poc/features/chat_list/presentation/widgets/chat_list_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../cubit/conversation_cubit.dart';
import '../cubit/conversation_state.dart';
import '../widgets/conversation_tile.dart';

import '../../../chat/presentation/screens/chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConversationCubit>()
        ..loadConversations(),
      child: const _ChatScreenContent(),
    );
  }
}

class _ChatScreenContent extends StatelessWidget {
  const _ChatScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<ConversationCubit, ConversationState>(
        builder: (context, state) {
          if (state is ConversationLoading) {
            return const ChatListShimmer();
          }

          if (state is ConversationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 55,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<ConversationCubit>()
                            .loadConversations();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ConversationEmpty) {
            return RefreshIndicator(
              onRefresh: () {
                return context
                    .read<ConversationCubit>()
                    .loadConversations();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Your conversations will appear here',
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ConversationLoaded) {
            return RefreshIndicator(
              onRefresh: () {
                return context
                    .read<ConversationCubit>()
                    .loadConversations();
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.conversations.length,
                separatorBuilder: (_, __) {
                  return const Divider(
                    height: 1,
                    indent: 80,
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
                          builder: (_) => ChatDetailScreen(
                            conversation: conversation,
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