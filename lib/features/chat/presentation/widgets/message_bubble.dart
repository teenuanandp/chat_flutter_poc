// ignore_for_file: unused_element, unused_field,unused_local_variable

import 'package:chat_flutter_poc/core/theme/app_theme.dart';
import 'package:chat_flutter_poc/features/chat/data/models/message_model.dart';
import 'package:flutter/material.dart';

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onReplyTap;

  final int previewLength;
  final int incrementLength;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReplyTap,
    this.previewLength = 500,
    this.incrementLength = 500,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late int _visibleLength;

  @override
  void initState() {
    super.initState();
    _visibleLength = widget.previewLength;
  }

  @override
  void didUpdateWidget(covariant MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.message.id != widget.message.id) {
      _visibleLength = widget.previewLength;
    }
  }

  String get _replySender {
    final reply = widget.message.replyTo;
    return reply?['senderName']?.toString() ?? 'Original message';
  }

  String get _replyContent {
    final reply = widget.message.replyTo;

    if (reply == null) return 'Message unavailable';

    if (reply['isDeleted'] == true) {
      return 'This message was deleted';
    }

    final content = reply['content']?.toString() ?? '';

    if (content.isNotEmpty) return content;

    final type = reply['type']?.toString() ?? 'Message';
    return '[$type]';
  }

  bool get _hasReply {
    return widget.message.replyToMessageId != null ||
        widget.message.replyTo != null;
  }

  String get _content {
    if (widget.message.isDeleted) {
      return 'This message was deleted';
    }

    return widget.message.content;
  }

  // Use Unicode runes to avoid cutting emoji in half.
  String get _visibleContent {
    final runes = _content.runes.toList();

    if (runes.length <= _visibleLength) {
      return _content;
    }

    return String.fromCharCodes(runes.take(_visibleLength));
  }

  bool get _hasMore {
    return _content.runes.length > _visibleLength;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final local = dateTime.toLocal();

    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;

    final minute = local.minute.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    bool isDark = theme.brightness == Brightness.dark;

    final tickColor = isDark ? colors.onPrimary : colors.secondary;

    final bubbleColor = widget.isMe ? colors.primary : colors.surface;

    final textColor = widget.isMe ? colors.onPrimary : colors.onSurface;

    final mutedColor = widget.isMe
        ? colors.onPrimary.withValues(alpha: 0.7)
        : colors.onSurfaceVariant;

    // Reply preview background
    final replyBackground = widget.isMe
        ? colors.onPrimary.withValues(alpha: 0.10)
        : colors.surfaceContainerHigh;

    // Reply accent
    final replyAccent = widget.isMe ? colors.onPrimary : colors.primary;

    // Read receipt color
    final readReceiptColor = colors.primary;

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(widget.isMe ? 16 : 4),
            bottomRight: Radius.circular(widget.isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hasReply)
              _buildReplyPreview(
                textColor: textColor,
                mutedColor: mutedColor,
                backgroundColor: replyBackground,
                accentColor: replyAccent,
              ),

            if (widget.message.isForwarded)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.forward, size: 14, color: mutedColor),
                    const SizedBox(width: 4),
                    Text(
                      'Forwarded',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            if (widget.message.isPinned)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.push_pin_outlined, size: 13, color: mutedColor),
                    const SizedBox(width: 4),
                    Text(
                      'Pinned message',
                      style: TextStyle(color: mutedColor, fontSize: 11),
                    ),
                  ],
                ),
              ),

            if (widget.message.isDeleted)
              Text(
                'This message was deleted',
                style: TextStyle(
                  color: mutedColor,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              _buildMessageContent(textColor, theme),

            if (_hasMore || _visibleLength > widget.previewLength)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      if (_hasMore) {
                        _visibleLength += widget.incrementLength;
                      } else {
                        _visibleLength = widget.previewLength;
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 0,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _hasMore ? 'Read more' : 'Read less',
                    style: TextStyle(
                      color: widget.isMe ? colors.onPrimary : colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 5),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.message.editedAtUtc != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text(
                      'Edited',
                      style: TextStyle(fontSize: 10, color: mutedColor),
                    ),
                  ),

                Text(
                  _formatTime(widget.message.createdAtUtc),
                  style: TextStyle(fontSize: 10, color: mutedColor),
                ),

                if (widget.isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(widget.message.status, isDark),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(Color textColor, ThemeData theme) {
    // For now, render text messages with Markdown.
    // Other message types can be handled separately.
    if (widget.message.type.toLowerCase() != 'text') {
      return Text(
        widget.message.content.isNotEmpty
            ? widget.message.content
            : '[${widget.message.type}]',
        style: TextStyle(color: textColor),
      );
    }

    return MarkdownBody(
      data: _visibleContent,
      selectable: true,
      shrinkWrap: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: textColor, fontSize: 14, height: 1.4),
        h1: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: textColor,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
        code: TextStyle(
          color: textColor,
          backgroundColor: widget.isMe
              ? theme.colorScheme.onPrimary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
        ),
        blockquote: TextStyle(color: textColor, fontStyle: FontStyle.italic),
        listBullet: TextStyle(color: textColor),
        a: TextStyle(
          color: widget.isMe
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status, bool isDark) {
    switch (status) {
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 15,
          color: isDark ? AppTheme.darkReadTickColor : AppTheme.readTickColor,
        );

      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 15,
          color: isDark
              ? AppTheme.darkDeliveredTickColor
              : AppTheme.deliveredTickColor,
        );

      case MessageStatus.sent:
        return Icon(
          Icons.done,
          size: 15,
          color: isDark ? AppTheme.darkSentTickColor : AppTheme.sentTickColor,
        );

      case MessageStatus.pending:
        return Icon(
          Icons.access_time,
          size: 13,
          color: isDark
              ? AppTheme.darkPendingTickColor
              : AppTheme.pendingTickColor,
        );
    }
  }

  Widget _buildReplyPreview({
    required Color textColor,
    required Color mutedColor,
    required Color backgroundColor,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: widget.onReplyTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: accentColor, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _replySender,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _replyContent,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
