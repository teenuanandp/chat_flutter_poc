
import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/models/api_response.dart';
import '../../../authentication/data/models/auth_user_model.dart';

class ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSource({
    required this.dioClient,
  });

  Future<AuthUserModel> getMyProfile() async {
    try {
      final response = await dioClient.apiDio.get(
        ApiEndpoints.myProfile,
      );

      final json = Map<String, dynamic>.from(response.data as Map);

      final apiResponse = ApiResponse<AuthUserModel>.fromJson(
        json,
        (data) => AuthUserModel.fromJson(
          Map<String, dynamic>.from(data as Map),
        ),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message.isNotEmpty
              ? apiResponse.message
              : 'Unable to load profile',
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map) {
        final message = responseData['message'];

        if (message is String && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception('Unable to load profile. Please try again.');
    }
  }
}
