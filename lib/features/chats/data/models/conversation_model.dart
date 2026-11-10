class ConversationModel {
  final String id;
  final String type;
  final String name;
  final String? peerName;
  final String lastMessage;
  final DateTime? lastActivityUtc;
  final int unreadCount;
  final bool isMuted;
  final bool isArchived;
  final int memberCount;

  const ConversationModel({
    required this.id,
    required this.type,
    required this.name,
    this.peerName,
    required this.lastMessage,
    this.lastActivityUtc,
    required this.unreadCount,
    required this.isMuted,
    required this.isArchived,
    required this.memberCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final peer = json['peer'] is Map
        ? Map<String, dynamic>.from(json['peer'])
        : <String, dynamic>{};

    final message = json['lastMessage'];

    String messagePreview = '';

    if (message is String) {
      messagePreview = message;
    } else if (message is Map) {
      messagePreview = (message['content'] ??
              message['text'] ??
              message['body'] ??
              '')
          .toString();
    }

    final peerName = (peer['displayName'] ??
            peer['name'] ??
            peer['username'])
        ?.toString();

    final displayName = (json['name'] ?? peerName ?? 'Unknown')
        .toString();

    return ConversationModel(
      id: json['id'].toString(),
      type: (json['type'] ?? 'Direct').toString(),
      name: displayName,
      peerName: peerName,
      lastMessage: messagePreview,
      lastActivityUtc: DateTime.tryParse(
        json['lastActivityUtc']?.toString() ?? '',
      ),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isMuted: json['isMuted'] == true,
      isArchived: json['isArchived'] == true,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }

  String get displayTime {
    final date = lastActivityUtc?.toLocal();

    if (date == null) return '';

    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $period';
    }

    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}