class ConversationModel {
  final String id;
  final String type;
  final String name;
  final String? description;
  final PeerModel? peer;
  final LastMessageModel? lastMessage;
  final DateTime? lastActivityUtc;
  final int lastSeq;
  final int unreadCount;
  final bool isMuted;
  final bool isArchived;
  final String myRole;
  final int memberCount;

  const ConversationModel({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.peer,
    this.lastMessage,
    this.lastActivityUtc,
    required this.lastSeq,
    required this.unreadCount,
    required this.isMuted,
    required this.isArchived,
    required this.myRole,
    required this.memberCount,
  });

  bool get isGroup => type.toLowerCase() == 'group';

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'Direct',
      name: json['name'] ?? 'Unknown',
      description: json['description'],
      peer: json['peer'] == null
          ? null
          : PeerModel.fromJson(json['peer']),
      lastMessage: json['lastMessage'] == null
          ? null
          : LastMessageModel.fromJson(json['lastMessage']),
      lastActivityUtc: json['lastActivityUtc'] == null
          ? null
          : DateTime.tryParse(json['lastActivityUtc']),
      lastSeq: json['lastSeq'] ?? 0,
      unreadCount: json['unreadCount'] ?? 0,
      isMuted: json['isMuted'] ?? false,
      isArchived: json['isArchived'] ?? false,
      myRole: json['myRole'] ?? 'Member',
      memberCount: json['memberCount'] ?? 0,
    );
  }
}

class PeerModel {
  final String id;
  final String userName;
  final String displayName;
  final String? about;
  final bool isOnline;
  final DateTime? lastSeenUtc;

  const PeerModel({
    required this.id,
    required this.userName,
    required this.displayName,
    this.about,
    required this.isOnline,
    this.lastSeenUtc,
  });

  factory PeerModel.fromJson(Map<String, dynamic> json) {
    return PeerModel(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      displayName: json['displayName'] ?? '',
      about: json['about'],
      isOnline: json['isOnline'] ?? false,
      lastSeenUtc: json['lastSeenUtc'] == null
          ? null
          : DateTime.tryParse(json['lastSeenUtc']),
    );
  }
}

class LastMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String type;
  final String preview;
  final DateTime? createdAtUtc;
  final int seq;
  final bool isDeleted;

  const LastMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.preview,
    this.createdAtUtc,
    required this.seq,
    required this.isDeleted,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      type: json['type'] ?? 'Text',
      preview: json['preview'] ?? '',
      createdAtUtc: json['createdAtUtc'] == null
          ? null
          : DateTime.tryParse(json['createdAtUtc']),
      seq: json['seq'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
