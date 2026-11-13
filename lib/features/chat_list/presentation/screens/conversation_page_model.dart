import 'package:chat_flutter_poc/features/chat_list/data/modals/conversation_model.dart';


class ConversationPageModel {
  final List<ConversationModel> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const ConversationPageModel({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory ConversationPageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationPageModel(
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (item) => ConversationModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
