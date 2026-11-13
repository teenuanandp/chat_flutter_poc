
import 'package:chat_flutter_poc/features/chat_list/presentation/screens/conversation_page_model.dart';
import 'package:dio/dio.dart';

import 'package:chat_flutter_poc/core/network/dio_client.dart';
import 'package:chat_flutter_poc/core/network/api_endpoints.dart';
import 'package:chat_flutter_poc/core/network/models/api_response.dart';
import 'package:flutter/widgets.dart';

class ConversationRemoteDataSource {
  final DioClient dioClient;

  ConversationRemoteDataSource({
    required this.dioClient,
  });

  Future<ConversationPageModel> getConversations({
    bool archived = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dioClient.apiDio.get(
        ApiEndpoints.conversations,
        queryParameters: {
          'archived': archived,
          'page': page,
          'pageSize': pageSize,
        },
      );

      final apiResponse = ApiResponse<ConversationPageModel>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => ConversationPageModel.fromJson(
          data as Map<String, dynamic>,
        ),
      );

      debugPrint("Here $apiResponse");

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message.isNotEmpty
              ? apiResponse.message
              : 'Unable to fetch conversations.',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;

      throw Exception(
        message ?? e.message ?? 'Network error occurred.',
      );
    }
  }

}
