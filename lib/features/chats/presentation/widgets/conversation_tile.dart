import 'package:flutter/material.dart';

import '../../data/models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel chat;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final initials = chat.name.isNotEmpty
        ? chat.name[0].toUpperCase()
        : '?';

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              initials,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (chat.isMuted)
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Icon(
                Icons.volume_off,
                size: 15,
              ),
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          chat.lastMessage.isEmpty
              ? 'No messages yet'
              : chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.displayTime,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 7),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${chat.unreadCount}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}