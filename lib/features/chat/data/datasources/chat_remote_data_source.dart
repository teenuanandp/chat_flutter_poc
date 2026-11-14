import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/models/api_response.dart';

import '../models/message_page_model.dart';

class ChatRemoteDataSource {
  final DioClient dioClient;

  ChatRemoteDataSource({
    required this.dioClient,
  });

  Future<MessagePageModel> getMessages({
    required String conversationId,
    int limit = 50,
    int? beforeSeq,
    int? afterSeq,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
      };

      if (beforeSeq != null) {
        queryParameters['beforeSeq'] = beforeSeq;
      }

      if (afterSeq != null) {
        queryParameters['afterSeq'] = afterSeq;
      }

      final response = await dioClient.apiDio.get(
        ApiEndpoints.conversationMessages(conversationId),
        queryParameters: queryParameters,
      );

      final apiResponse =
          ApiResponse<MessagePageModel>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => MessagePageModel.fromJson(
          data as Map<String, dynamic>,
        ),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message.isNotEmpty
              ? apiResponse.message
              : 'Unable to fetch messages.',
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
    } catch (e) {
      debugPrint('Get messages error: $e');
      rethrow;
    }
  }
}