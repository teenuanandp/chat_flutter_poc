import 'message_model.dart';

class MessagePageModel {
  final List<MessageModel> items;
  final bool hasMore;

  const MessagePageModel({
    required this.items,
    required this.hasMore,
  });

  factory MessagePageModel.fromJson(Map<String, dynamic> json) {
    return MessagePageModel(
      items: (json['items'] as List? ?? [])
          .map(
            (item) => MessageModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}