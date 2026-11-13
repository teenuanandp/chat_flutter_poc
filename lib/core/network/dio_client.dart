
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

class DioClient {
  late final Dio authDio;
  late final Dio apiDio;

  final SecureStorageService secureStorage;

  DioClient({
    required this.secureStorage,
  }) {
    authDio = Dio(_baseOptions());
    apiDio = Dio(_baseOptions());

    _addAccessTokenInterceptor();
  }

  BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.json,
    );
  }

  void _addAccessTokenInterceptor() {
    apiDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final accessToken =
                await secureStorage.getAccessToken();

            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] =
                  'Bearer $accessToken';
            }

            handler.next(options);
          } catch (error) {

            debugPrint('\n ==================== Here the API problem ===================== \n $error.toString() \n');
            
            handler.reject(
              DioException(
                requestOptions: options,
                error: error,
                message: 'Unable to read the authentication token.',
              ),
            );
          }
        },
      ),
    );
  }
}
