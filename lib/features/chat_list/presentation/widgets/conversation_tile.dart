
import 'package:chat_flutter_poc/core/shared/widgets/avatar/app_avatar.dart';
import 'package:chat_flutter_poc/features/chat_list/data/modals/conversation_model.dart';
import 'package:flutter/material.dart';

import 'avatar_preview_screen.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  String _getDisplayName() {
    if (!conversation.isGroup &&
        conversation.peer != null) {
      return conversation.peer!.displayName.isNotEmpty
          ? conversation.peer!.displayName
          : conversation.name;
    }

    return conversation.name;
  }

  String _getLastMessage() {
    final message = conversation.lastMessage;

    if (message == null) {
      return 'No messages yet';
    }

    if (message.isDeleted) {
      return 'This message was deleted';
    }

    String preview = message.preview;

    if (preview.isEmpty) {
      switch (message.type.toLowerCase()) {
        case 'image':
          return '📷 Image';
        case 'file':
          return '📎 File';
        case 'audio':
          return '🎵 Audio';
        default:
          return 'Message';
      }
    }

    if (conversation.isGroup) {
      return '${message.senderName}: $preview';
    }

    return preview;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final localTime = dateTime.toLocal();
    final now = DateTime.now();

    final isToday =
        localTime.year == now.year &&
        localTime.month == now.month &&
        localTime.day == now.day;

    if (isToday) {
      final hour = localTime.hour % 12 == 0
          ? 12
          : localTime.hour % 12;

      final minute = localTime.minute.toString().padLeft(2, '0');
      final period = localTime.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $period';
    }

    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));

    if (localTime.year == yesterday.year &&
        localTime.month == yesterday.month &&
        localTime.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${localTime.day}/${localTime.month}/${localTime.year}';
  }

  void _openAvatar(BuildContext context, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvatarPreviewScreen(name: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final displayName = _getDisplayName();

    final activityTime = conversation.lastMessage?.createdAtUtc ??
        conversation.lastActivityUtc;

    final isOnline = !conversation.isGroup &&
        (conversation.peer?.isOnline ?? false);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _openAvatar(context, displayName),
              child: Stack(
                children: [
                  AppAvatar(
                    displayName: displayName,
                    size: 52,
                  ),

                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      if (conversation.isMuted)
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.volume_off_outlined,
                            size: 16,
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                      Text(
                        _formatTime(activityTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getLastMessage(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),

                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : '${conversation.unreadCount}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
