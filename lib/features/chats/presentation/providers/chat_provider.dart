import 'package:flutter/material.dart';

import '../../data/models/conversation_model.dart';
import '../../data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;

  ChatProvider(this._chatService);

  List<ConversationModel> _chats = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 1;
  final int _pageSize = 20;

  bool _hasMore = true;
  String _searchQuery = '';

  List<ConversationModel> get chats {
    if (_searchQuery.trim().isEmpty) return _chats;

    return _chats.where((chat) {
      return chat.name.toLowerCase().contains(
            _searchQuery.trim().toLowerCase(),
          );
    }).toList();
  }

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> loadChats({bool refresh = false}) async {
    if (_isLoading || _isLoadingMore) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _chatService.getConversations(
        archived: false,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _chats = result;
      } else {
        _chats = [..._chats, ...result];
      }

      _hasMore = result.length == _pageSize;

      if (_hasMore) {
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _chatService.getConversations(
        archived: false,
        page: _currentPage,
        pageSize: _pageSize,
      );

      _chats = [..._chats, ...result];
      _hasMore = result.length == _pageSize;

      if (_hasMore) {
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void searchChats(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> retry() => loadChats(refresh: true);
}