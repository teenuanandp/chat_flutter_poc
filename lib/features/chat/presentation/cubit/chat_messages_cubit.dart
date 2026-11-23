import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/realtime/signalr_service.dart';
import 'chat_messages_state.dart';

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final ChatRepository repository;
  final SignalRService signalRService;

  StreamSubscription<MessageModel>? _messageSubscription;
  // Remote typing state for the active conversation.
  final ValueNotifier<bool> isOtherUserTyping = ValueNotifier(false);

  // SignalR typing subscription.
  StreamSubscription<TypingEvent>? _typingSubscription;

  // Current conversation and user.
  String? _activeConversationId;
  String? _currentUserId;

  // Local typing control.
  Timer? _typingStopTimer;
  DateTime? _lastTypingStartedAt;
  bool _isLocalTyping = false;

  // Remote typing expiry.
  Timer? _remoteTypingTimer;

  // Holds messages received while REST history is loading.
  final List<MessageModel> _pendingMessages = [];

  ChatMessagesCubit({required this.repository, required this.signalRService})
    : super(ChatMessagesInitial()) {
    // Subscribe once when this Cubit is created.
    _messageSubscription = signalRService.incomingMessages.listen(addMessage);
    _typingSubscription = signalRService.typingEvents.listen(
      _handleTypingEvent,
    );
  }

  static const int pageSize = 50;

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  void setActiveConversation(String conversationId) {
    _activeConversationId = conversationId;
    isOtherUserTyping.value = false;
    _remoteTypingTimer?.cancel();
  }

  void _handleTypingEvent(TypingEvent event) {
    if (event.conversationId != _activeConversationId) return;

    // Ignore our own typing events.
    if (event.userId == _currentUserId) return;

    _remoteTypingTimer?.cancel();

    if (event.isTyping) {
      isOtherUserTyping.value = true;

      // Automatically clear stale typing indicators.
      _remoteTypingTimer = Timer(const Duration(seconds: 5), () {
        isOtherUserTyping.value = false;
      });
    } else {
      isOtherUserTyping.value = false;
    }
  }

  void stopLocalTyping(String conversationId) {
    _typingStopTimer?.cancel();

    if (!_isLocalTyping) return;

    _isLocalTyping = false;

    signalRService.typingStopped(conversationId).catchError((error) {
      debugPrint('TYPING STOP FAILED: $error');
    });
  }

  void onLocalTyping(String conversationId) {
    final now = DateTime.now();

    // Send TypingStarted at most once every 2 seconds.
    final shouldNotifyServer =
        _lastTypingStartedAt == null ||
        now.difference(_lastTypingStartedAt!) >= const Duration(seconds: 2);

    if (shouldNotifyServer) {
      _lastTypingStartedAt = now;
      _isLocalTyping = true;

      signalRService.typingStarted(conversationId).catchError((error) {
        debugPrint('TYPING START FAILED: $error');
      });
    }

    // Stop typing after the user pauses.
    _typingStopTimer?.cancel();

    _typingStopTimer = Timer(const Duration(milliseconds: 1500), () {
      stopLocalTyping(conversationId);
    });
  }

  Future<void> loadMessages(String conversationId) async {
    setActiveConversation(conversationId);
    _activeConversationId = conversationId;
    _pendingMessages.clear();

    emit(ChatMessagesLoading());

    try {
      final result = await repository.getMessages(
        conversationId: conversationId,
        limit: pageSize,
      );

      // Ignore an old request if another conversation was opened.
      if (_activeConversationId != conversationId) return;

      // Merge REST history and messages received during loading.
      final messagesById = <String, MessageModel>{};

      for (final message in result.items) {
        messagesById[message.id] = message;
      }

      for (final message in _pendingMessages) {
        if (message.conversationId == conversationId) {
          messagesById[message.id] = message;
        }
      }

      _pendingMessages.clear();

      final messages = messagesById.values.toList()
        ..sort((a, b) => a.seq.compareTo(b.seq));

      if (messages.isEmpty) {
        emit(ChatMessagesEmpty());
        return;
      }

      emit(ChatMessagesLoaded(messages: messages, hasMore: result.hasMore));
    } catch (e) {
      if (_activeConversationId != conversationId) return;

      emit(ChatMessagesError(e.toString().replaceFirst('Exception: ', '')));
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

      // Read the latest state after awaiting the API.
      // This prevents losing messages received during pagination.
      final latestState = state;

      if (latestState is! ChatMessagesLoaded) return;

      final messagesById = <String, MessageModel>{};

      for (final message in result.items) {
        messagesById[message.id] = message;
      }

      for (final message in latestState.messages) {
        messagesById[message.id] = message;
      }

      final messages = messagesById.values.toList()
        ..sort((a, b) => a.seq.compareTo(b.seq));

      emit(ChatMessagesLoaded(messages: messages, hasMore: result.hasMore));
    } catch (_) {
      final latestState = state;

      if (latestState is ChatMessagesLoaded) {
        emit(
          ChatMessagesLoaded(
            messages: latestState.messages,
            hasMore: latestState.hasMore,
          ),
        );
      }
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final text = content.trim();

    if (text.isEmpty) return;

    try {
      final message = await signalRService.sendTextMessage(
        conversationId: conversationId,
        content: text,
      );

      // Add the server-acknowledged message to the UI.
      // ReceiveMessage may also deliver the same message.
      // addMessage() must deduplicate using message.id.
      addMessage(message);
    } catch (error, stackTrace) {
      debugPrint('CHAT CUBIT SEND FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // Called automatically whenever SignalR publishes a message.
  void addMessage(MessageModel message) {
    // Don't show messages belonging to another conversation.
    if (message.conversationId != _activeConversationId) {
      return;
    }

    final currentState = state;

    // REST history is still loading. Buffer the message.
    if (currentState is ChatMessagesLoading ||
        currentState is ChatMessagesInitial) {
      if (!_pendingMessages.any((m) => m.id == message.id)) {
        _pendingMessages.add(message);
      }
      return;
    }

    final messages = currentState is ChatMessagesLoaded
        ? List<MessageModel>.from(currentState.messages)
        : <MessageModel>[];

    // SignalR may echo a message already present in REST or local state.
    if (messages.any((m) => m.id == message.id)) {
      return;
    }

    messages.add(message);

    // Keep server sequence ordering.
    messages.sort((a, b) => a.seq.compareTo(b.seq));

    emit(
      ChatMessagesLoaded(
        messages: messages,
        hasMore: currentState is ChatMessagesLoaded
            ? currentState.hasMore
            : false,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _messageSubscription?.cancel();
    await _typingSubscription?.cancel();

    _typingStopTimer?.cancel();
    _remoteTypingTimer?.cancel();

    if (_activeConversationId != null) {
      stopLocalTyping(_activeConversationId!);
    }

    isOtherUserTyping.dispose();

    await super.close();
  }
}
