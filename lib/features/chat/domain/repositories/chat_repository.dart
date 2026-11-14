import '../../data/models/message_page_model.dart';

abstract class ChatRepository {
  Future<MessagePageModel> getMessages({
    required String conversationId,
    int limit,
    int? beforeSeq,
    int? afterSeq,
  });
}