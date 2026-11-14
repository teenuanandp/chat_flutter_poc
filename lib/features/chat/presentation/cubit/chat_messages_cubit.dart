import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_messages_state.dart';

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final ChatRepository repository;

  ChatMessagesCubit({
    required this.repository,
  }) : super(ChatMessagesInitial());

  static const int pageSize = 50;

  Future<void> loadMessages(String conversationId) async {
    emit(ChatMessagesLoading());

    try {
      final result = await repository.getMessages(
        conversationId: conversationId,
        limit: pageSize,
      );

      if (result.items.isEmpty) {
        emit(ChatMessagesEmpty());
        return;
      }

      // API returns oldest first.
      // Keep the same ordering in the UI.
      emit(
        ChatMessagesLoaded(
          messages: result.items,
          hasMore: result.hasMore,
        ),
      );
    } catch (e) {
      emit(
        ChatMessagesError(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> loadOlderMessages(String conversationId) async {
    final currentState = state;

    if (currentState is! ChatMessagesLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;
    if (currentState.messages.isEmpty) return;

    emit(
      ChatMessagesLoaded(
        messages: currentState.messages,
        hasMore: currentState.hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final oldestSeq = currentState.messages.first.seq;

      final result = await repository.getMessages(
        conversationId: conversationId,
        limit: pageSize,
        beforeSeq: oldestSeq,
      );

      final existingIds = currentState.messages
          .map((message) => message.id)
          .toSet();

      final olderMessages = result.items
          .where((message) => !existingIds.contains(message.id))
          .toList();

      emit(
        ChatMessagesLoaded(
          messages: [
            ...olderMessages,
            ...currentState.messages,
          ],
          hasMore: result.hasMore,
        ),
      );
    } catch (_) {
      // Preserve the existing messages if pagination fails.
      emit(
        ChatMessagesLoaded(
          messages: currentState.messages,
          hasMore: currentState.hasMore,
        ),
      );
    }
  }

  void addMessage(MessageModel message) {
    final currentState = state;

    if (currentState is ChatMessagesLoaded) {
      if (currentState.messages.any((m) => m.id == message.id)) {
        return;
      }

      emit(
        ChatMessagesLoaded(
          messages: [...currentState.messages, message],
          hasMore: currentState.hasMore,
        ),
      );
    } else {
      emit(
        ChatMessagesLoaded(
          messages: [message],
          hasMore: false,
        ),
      );
    }
  }
}