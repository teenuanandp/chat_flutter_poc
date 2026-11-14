import 'package:equatable/equatable.dart';

import '../../data/models/message_model.dart';

abstract class ChatMessagesState extends Equatable {
  const ChatMessagesState();

  @override
  List<Object?> get props => [];
}

class ChatMessagesInitial extends ChatMessagesState {}

class ChatMessagesLoading extends ChatMessagesState {}

class ChatMessagesLoaded extends ChatMessagesState {
  final List<MessageModel> messages;
  final bool hasMore;
  final bool isLoadingMore;

  const ChatMessagesLoaded({
    required this.messages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        messages,
        hasMore,
        isLoadingMore,
      ];
}

class ChatMessagesEmpty extends ChatMessagesState {}

class ChatMessagesError extends ChatMessagesState {
  final String message;

  const ChatMessagesError(this.message);

  @override
  List<Object?> get props => [message];
}