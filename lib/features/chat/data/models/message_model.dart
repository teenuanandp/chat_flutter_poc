class MessageModel {
  final String id;
  final String conversationId;
  final int seq;
  final String senderId;
  final String senderName;
  final String type;
  final String content;
  final String? replyToMessageId;
  final Map<String, dynamic>? replyTo;
  final bool isForwarded;
  final DateTime? createdAtUtc;
  final DateTime? editedAtUtc;
  final bool isDeleted;
  final bool isPinned;
  final List<dynamic> attachments;
  final List<dynamic> reactions;
  final MessageStatus status;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.seq,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.content,
    this.replyToMessageId,
    this.replyTo,
    required this.isForwarded,
    this.createdAtUtc,
    this.editedAtUtc,
    required this.isDeleted,
    required this.isPinned,
    required this.attachments,
    required this.reactions,
    required this.status,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      seq: (json['seq'] as num?)?.toInt() ?? 0,
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Text',
      content: json['content']?.toString() ?? '',
      replyToMessageId: json['replyToMessageId']?.toString(),
      replyTo: json['replyTo'] as Map<String, dynamic>?,
      isForwarded: json['isForwarded'] as bool? ?? false,
      createdAtUtc: json['createdAtUtc'] != null
          ? DateTime.tryParse(json['createdAtUtc'].toString())
          : null,
      editedAtUtc: json['editedAtUtc'] != null
          ? DateTime.tryParse(json['editedAtUtc'].toString())
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      attachments: json['attachments'] as List? ?? [],
      reactions: json['reactions'] as List? ?? [],
      status: MessageStatus.fromJson(json['status']),
    );
  }
}

enum MessageStatus {
  sent,
  delivered,
  read,
  pending;

  static MessageStatus fromJson(dynamic value) {
    switch (value?.toString().toLowerCase()) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.pending;
    }
  }
}