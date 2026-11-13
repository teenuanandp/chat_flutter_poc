
import 'package:chat_flutter_poc/features/chat_list/presentation/screens/conversation_page_model.dart';

abstract class ConversationRepository {
  Future<ConversationPageModel> getConversations({
    bool archived,
    int page,
    int pageSize,
  });
}