import 'package:chat_flutter_poc/features/chat_list/data/modals/conversation_model.dart';
import 'package:equatable/equatable.dart';


abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<ConversationModel> conversations;

  const ConversationLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ConversationEmpty extends ConversationState {}

class ConversationError extends ConversationState {
  final String message;

  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}