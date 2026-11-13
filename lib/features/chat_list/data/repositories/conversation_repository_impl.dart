import 'package:chat_flutter_poc/features/chat_list/presentation/screens/conversation_page_model.dart';

import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_remote_data_source.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationRemoteDataSource remoteDataSource;

  ConversationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<ConversationPageModel> getConversations({
    bool archived = false,
    int page = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getConversations(
      archived: archived,
      page: page,
      pageSize: pageSize,
    );
  }
}