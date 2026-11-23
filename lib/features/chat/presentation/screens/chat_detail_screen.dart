import 'package:chat_flutter_poc/core/shared/widgets/avatar/app_avatar.dart';
import 'package:chat_flutter_poc/features/chat_list/data/modals/conversation_model.dart';
import 'package:chat_flutter_poc/features/profile/data/storage/profile_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/chat_messages_cubit.dart';
import '../cubit/chat_messages_state.dart';

import '../widgets/message_bubble.dart';
import '../widgets/message_list_shimmer.dart';

class ChatDetailScreen extends StatefulWidget {
  final ConversationModel conversation;
  final ProfileLocalStorage profileLocalStorage;

  const ChatDetailScreen({
    super.key,
    required this.conversation,
    required this.profileLocalStorage,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  String? currentUserId;

  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  bool _isSending = false;

  bool _showScrollToBottom = false;
  int _newMessagesCount = 0;

  String? _lastMessageId;

  static const double _bottomThreshold = 100;

  String get displayName {
    if (!widget.conversation.isGroup && widget.conversation.peer != null) {
      final name = widget.conversation.peer!.displayName;

      return name.isNotEmpty ? name : widget.conversation.name;
    }

    return widget.conversation.name;
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadCurrentUser() async {
    final profile = await widget.profileLocalStorage.getProfile();

    if (!mounted) return;

    setState(() {
      currentUserId = profile?.id;
    });

    if (currentUserId != null) {
      context.read<ChatMessagesCubit>().setCurrentUserId(currentUserId!);
    }
  }

  void _onMessagesUpdated(ChatMessagesState state) {
    if (state is! ChatMessagesLoaded || state.messages.isEmpty) {
      return;
    }

    final latestMessage = state.messages.last;

    // Initial load: remember the latest message.
    if (_lastMessageId == null) {
      _lastMessageId = latestMessage.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToBottom();
        }
      });
      return;
    }

    // No new message.
    if (_lastMessageId == latestMessage.id) {
      return;
    }

    _lastMessageId = latestMessage.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final position = _scrollController.position;

      final isNearBottom =
          position.maxScrollExtent - position.pixels <= _bottomThreshold;

      // My own message or user already at bottom:
      // automatically show the latest message.
      if (latestMessage.senderId == currentUserId || isNearBottom) {
        _newMessagesCount = 0;
        _scrollToBottom();
        return;
      }

      // Another user sent a message while we are reading older messages.
      setState(() {
        _newMessagesCount++;
        _showScrollToBottom = true;
      });
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    final isNearBottom =
        position.maxScrollExtent - position.pixels <= _bottomThreshold;

    final shouldShowButton = !isNearBottom;
    final shouldResetCount = isNearBottom && _newMessagesCount > 0;

    if (_showScrollToBottom != shouldShowButton || shouldResetCount) {
      setState(() {
        _showScrollToBottom = shouldShowButton;

        if (shouldResetCount) {
          _newMessagesCount = 0;
        }
      });
    }

    if (position.pixels <= 100) {
      context.read<ChatMessagesCubit>().loadOlderMessages(
        widget.conversation.id,
      );
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    setState(() {
      _newMessagesCount = 0;
    });

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      // stop typing indication
      context.read<ChatMessagesCubit>().stopLocalTyping(widget.conversation.id);

      await context.read<ChatMessagesCubit>().sendMessage(
        conversationId: widget.conversation.id,
        content: text,
      );

      if (!mounted) return;

      // Clear only if the input still contains the sent text.
      if (_messageController.text.trim() == text) {
        _messageController.clear();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToBottom();
        }
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Message sending failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AppAvatar(displayName: displayName, size: 38),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: context
                        .read<ChatMessagesCubit>()
                        .isOtherUserTyping,
                    builder: (context, isTyping, child) {
                      if (isTyping) {
                        return const Text(
                          'Typing...',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }

                      return Text(
                        widget.conversation.peer?.isOnline == true
                            ? 'Online'
                            : 'Offline',
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatMessagesCubit, ChatMessagesState>(
              listener: (context, state) {
                _onMessagesUpdated(state);
              },
              builder: (context, state) {
                if (state is ChatMessagesLoading) {
                  return const MessageListShimmer();
                }

                if (state is ChatMessagesError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_outlined, size: 50),
                          const SizedBox(height: 12),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ChatMessagesCubit>().loadMessages(
                                widget.conversation.id,
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ChatMessagesEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Icon(Icons.chat_bubble_outline, size: 55),
                      SizedBox(height: 12),
                      Center(child: Text('Start your conversation')),
                    ],
                  );
                }

                if (state is ChatMessagesLoaded) {
                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            state.messages.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (state.isLoadingMore && index == 0) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final messageIndex =
                              index - (state.isLoadingMore ? 1 : 0);

                          final message = state.messages[messageIndex];

                          final isMe = message.senderId == currentUserId;

                          return MessageBubble(
                            key: ValueKey(message.id),
                            message: message,
                            isMe: isMe,
                            previewLength: 500,
                            incrementLength: 500,
                          );
                        },
                      ),

                      if (_showScrollToBottom)
                        Positioned(
                          right: 8,
                          bottom: 12,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(30),
                            color: colors.surface,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: _scrollToBottom,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: _newMessagesCount > 0 ? 14 : 10,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_newMessagesCount > 0) ...[
                                      Text(
                                        '$_newMessagesCount new message${_newMessagesCount > 1 ? 's' : ''}',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: colors.onSurface,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],

                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 24,
                                      color: colors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          _buildMessageInput(colors),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ColorScheme colors) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file)),

            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  final cubit = context.read<ChatMessagesCubit>();

                  if (value.trim().isNotEmpty) {
                    cubit.onLocalTyping(widget.conversation.id);
                  } else {
                    cubit.stopLocalTyping(widget.conversation.id);
                  }
                },
                onSubmitted: (_) => _sendMessage(),
              ),
            ),

            const SizedBox(width: 8),

            CircleAvatar(
              backgroundColor: colors.primary,
              child: IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    : Icon(Icons.send, color: colors.onPrimary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
