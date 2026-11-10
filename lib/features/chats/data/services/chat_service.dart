import 'package:dio/dio.dart';

import '../models/conversation_model.dart';

class ChatService {
  final Dio _dio;

  ChatService(this._dio);

  Future<List<ConversationModel>> getConversations({
    bool archived = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      '/api/conversations',
      queryParameters: {
        'archived': archived,
        'page': page,
        'pageSize': pageSize,
      },
    );

    dynamic responseData = response.data;

    // Support both direct API responses and the common
    // { statusCode, success, message, data } envelope.
    if (responseData is Map &&
        responseData['data'] is Map) {
      responseData = responseData['data'];
    }

    if (responseData is! Map) {
      throw Exception('Unexpected conversation response.');
    }

    final items = responseData['items'];

    if (items is! List) {
      throw Exception('Conversation response does not contain items.');
    }

    return items
        .whereType<Map>()
        .map(
          (item) => ConversationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}