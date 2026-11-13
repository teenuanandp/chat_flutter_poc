
import 'package:chat_flutter_poc/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:chat_flutter_poc/features/profile/data/storage/profile_local_storage.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/models/api_response.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/auth_requests.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  final DioClient dioClient;
  final SecureStorageService secureStorage;

  // Profile DI
  final ProfileRemoteDataSource profileRemoteDataSource;
  final ProfileLocalStorage profileLocalStorage;

  AuthRemoteDataSource({
    required this.dioClient,
    required this.secureStorage,
    required this.profileLocalStorage,
    required this.profileRemoteDataSource
  });

  Future<AuthSession?> restoreSession() async {
  final refreshToken = await secureStorage.getRefreshToken();

  if (refreshToken == null || refreshToken.isEmpty) {
    return null;
  }

  try {
    final response = await dioClient.authDio.post(
      ApiEndpoints.refresh,
      data: RefreshRequest(
        refreshToken: refreshToken,
      ).toJson(),
    );

    final apiResponse = ApiResponse<AuthSession>.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      (json) => AuthSession.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    final session = apiResponse.data!;

    // Refresh tokens are rotated, so replace both.
    await secureStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );

    final latestProfile =  await profileRemoteDataSource.getMyProfile();

    await profileLocalStorage.saveProfile(latestProfile);

    return session;
  } on DioException catch (error) {
    if (error.response?.statusCode == 401) {
      await secureStorage.clearTokens();
      return null;
    }

    // Keep tokens if this is a network/server problem.
    rethrow;
  } catch (_) {
    await secureStorage.clearTokens();
    return null;
  }
}

  Future<AuthSession> login(LoginRequest request) async {
    try {
      final response = await dioClient.authDio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<AuthSession>.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (json) => AuthSession.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message);
      }

      final session = apiResponse.data!;

      // Save profile data
      await profileLocalStorage.saveProfile(session.user);

      // Save both tokens after successful login.
      await secureStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      // Use Me APi to save the users details
      final latestProfile =  await profileRemoteDataSource.getMyProfile();

      await profileLocalStorage.saveProfile(latestProfile);

      return session;
    } on DioException catch (error) {
      final responseData = error.response?.data;

      if (responseData is Map) {
        final message = responseData['message']?.toString();

        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(
        error.message ?? 'Unable to connect to the server.',
      );
    }
  }

  Future<bool> logout({
    required bool logoutFromAllDevices,
  }) async {
    final refreshToken = await secureStorage.getRefreshToken();

    try {
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await dioClient.apiDio.post(
        ApiEndpoints.logout,
        data: {
          'refreshToken': refreshToken,
          'allDevices': logoutFromAllDevices,
        },
      );

      // Convert backend JSON into ApiResponse.
      final apiResponse = ApiResponse<dynamic>.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (json) => json,
      );

      // Check backend success.
      if (!apiResponse.success) {
        throw Exception(apiResponse.message);
      }

      return true;

    } on DioException catch (error) {
      final responseData = error.response?.data;

      if (responseData is Map) {
        final message = responseData['message']?.toString();

        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(
        error.message ?? 'Unable to logout.',
      );

    } finally {
      // Always clear local session data.
      await secureStorage.clearTokens();
      await profileLocalStorage.clearProfile();
    }
  }

}
