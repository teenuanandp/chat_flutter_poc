import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/chat_service.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;

  static const int _pageSize = 20;

  int _currentPage = 1;

  ChatCubit(this._chatService) : super(const ChatState());

  Future<void> loadChats({bool refresh = false}) async {
    if (state.status == ChatStatus.loading) return;

    if (refresh) {
      _currentPage = 1;
    }

    emit(
      state.copyWith(
        status: ChatStatus.loading,
        clearError: true,
      ),
    );

    try {
      final result = await _chatService.getConversations(
        archived: false,
        page: 1,
        pageSize: _pageSize,
      );

      _currentPage = 2;

      emit(
        state.copyWith(
          status: ChatStatus.success,
          chats: result,
          hasMore: result.length == _pageSize,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.status != ChatStatus.success) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _chatService.getConversations(
        archived: false,
        page: _currentPage,
        pageSize: _pageSize,
      );

      _currentPage++;

      emit(
        state.copyWith(
          chats: [...state.chats, ...result],
          hasMore: result.length == _pageSize,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void searchChats(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> retry() => loadChats(refresh: true);
}