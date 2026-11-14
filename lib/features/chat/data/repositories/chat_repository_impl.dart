import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_page_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<MessagePageModel> getMessages({
    required String conversationId,
    int limit = 50,
    int? beforeSeq,
    int? afterSeq,
  }) {
    return remoteDataSource.getMessages(
      conversationId: conversationId,
      limit: limit,
      beforeSeq: beforeSeq,
      afterSeq: afterSeq,
    );
  }
}