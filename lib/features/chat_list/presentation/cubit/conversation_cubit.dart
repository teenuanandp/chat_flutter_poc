import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/conversation_repository.dart';
import 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  final ConversationRepository repository;

  ConversationCubit({
    required this.repository,
  }) : super(ConversationInitial());

  // Future<void> loadConversations() async {
  //   emit(ConversationLoading());

  //   try {
  //     final result = await repository.getConversations(
  //       archived: false,
  //       page: 1,
  //       pageSize: 20,
  //     );

  //     if (result.items.isEmpty) {
  //       emit(ConversationEmpty());
  //     } else {
  //       emit(ConversationLoaded(result.items));
  //     }
  //   } catch (e) {
  //     emit(
  //       ConversationError(
  //         e.toString().replaceFirst('Exception: ', ''),
  //       ),
  //     );
  //   }
  // }

  Future<void> loadConversations() async {
  emit(ConversationLoading());

  try {
    debugPrint('Loading conversations...');

    final result = await repository.getConversations(
      archived: false,
      page: 1,
      pageSize: 20,
    );

    debugPrint('Total conversations: ${result.items.length}');

    if (result.items.isEmpty) {
      emit(ConversationEmpty());
    } else {
      emit(ConversationLoaded(result.items));
    }
  } catch (e, stackTrace) {
    debugPrint('========== CONVERSATION ERROR ==========');
    debugPrint('Error: $e');
    debugPrint('StackTrace: $stackTrace');

    emit(
      ConversationError(
        e.toString().replaceFirst('Exception: ', ''),
      ),
    );
  }
}

}