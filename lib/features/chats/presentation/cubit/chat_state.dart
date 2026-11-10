import 'package:equatable/equatable.dart';

import '../../data/models/conversation_model.dart';

enum ChatStatus {
  initial,
  loading,
  success,
  failure,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ConversationModel> chats;
  final String? errorMessage;
  final String searchQuery;
  final bool isLoadingMore;
  final bool hasMore;

  const ChatState({
    this.status = ChatStatus.initial,
    this.chats = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  List<ConversationModel> get filteredChats {
    if (searchQuery.trim().isEmpty) return chats;

    return chats.where((chat) {
      return chat.name.toLowerCase().contains(
            searchQuery.trim().toLowerCase(),
          );
    }).toList();
  }

  ChatState copyWith({
    ChatStatus? status,
    List<ConversationModel>? chats,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return ChatState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        chats,
        errorMessage,
        searchQuery,
        isLoadingMore,
        hasMore,
      ];
}