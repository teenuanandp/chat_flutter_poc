import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

class DioClient {
  late final Dio authDio;
  late final Dio apiDio;

  final SecureStorageService secureStorage;

  // Shared refresh operation.
  Future<String?>? _refreshFuture;

  DioClient({required this.secureStorage}) {
    authDio = Dio(_baseOptions());
    apiDio = Dio(_baseOptions());

    _addAccessTokenInterceptor();
    _addTokenRefreshInterceptor();

    if (kDebugMode) {
      _addLoggingInterceptor();
    }
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

  // --------------------------------------------------
  // ACCESS TOKEN
  // --------------------------------------------------

  void _addAccessTokenInterceptor() {
    apiDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final accessToken = await secureStorage.getAccessToken();

            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }

            handler.next(options);
          } catch (error) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: error,
                message: 'Unable to read authentication token.',
              ),
            );
          }
        },
      ),
    );
  }

  // --------------------------------------------------
  // AUTOMATIC TOKEN REFRESH
  // --------------------------------------------------

  void _addTokenRefreshInterceptor() {
    apiDio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final request = error.requestOptions;

          final isUnauthorized = error.response?.statusCode == 401;

          final alreadyRetried = request.extra['retryAfterRefresh'] == true;

          if (!isUnauthorized || alreadyRetried) {
            return handler.next(error);
          }

          try {
            final newAccessToken = await _refreshAccessToken();

            if (newAccessToken == null) {
              return handler.next(error);
            }

            // Retry the original request only once.
            request.extra['retryAfterRefresh'] = true;

            request.headers['Authorization'] = 'Bearer $newAccessToken';

            final response = await apiDio.fetch(request);

            return handler.resolve(response);
          } catch (refreshError) {
            debugPrint('Token refresh failed: $refreshError');

            return handler.next(error);
          }
        },
      ),
    );
  }

  // --------------------------------------------------
  // REFRESH TOKEN
  // --------------------------------------------------

  Future<String?> _refreshAccessToken() {
    // Reuse an ongoing refresh operation.
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    final future = _performTokenRefresh();
    _refreshFuture = future;

    return future.whenComplete(() {
      _refreshFuture = null;
    });
  }


Future<String?> _performTokenRefresh() async {
  try {
    final refreshToken =
        await secureStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Refresh token unavailable.');
    }

    final response = await authDio.post(
      ApiEndpoints.refresh,
      data: {
        'refreshToken': refreshToken,
      },
    );

    final responseData =
        Map<String, dynamic>.from(response.data as Map);

    if (responseData['success'] != true ||
        responseData['data'] == null) {
      throw Exception(
        responseData['message'] ?? 'Refresh failed.',
      );
    }

    final session = Map<String, dynamic>.from(
      responseData['data'] as Map,
    );

    final accessToken =
        session['accessToken']?.toString();

    final newRefreshToken =
        session['refreshToken']?.toString();

    if (accessToken == null ||
        accessToken.isEmpty ||
        newRefreshToken == null ||
        newRefreshToken.isEmpty) {
      throw Exception('Invalid refresh response.');
    }

    // Save both rotated tokens.
    await secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
    );

    return accessToken;

  } on DioException catch (error) {

    // Refresh token rejected: clear session.
    if (error.response?.statusCode == 401) {
      await secureStorage.clearTokens();
    }

    // Preserve tokens for network/server errors.
    rethrow;
  }
}


  // --------------------------------------------------
  // LOGGING
  // --------------------------------------------------

  void _addLoggingInterceptor() {
    apiDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('========== API REQUEST ==========');
          debugPrint('URL: ${options.uri}');
          debugPrint('METHOD: ${options.method}');

          // Never print JWT tokens.
          final safeHeaders = Map<String, dynamic>.from(options.headers);

          if (safeHeaders.containsKey('Authorization')) {
            safeHeaders['Authorization'] = '[REDACTED]';
          }

          debugPrint('HEADERS: $safeHeaders');

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('========== API RESPONSE ==========');
          debugPrint('URL: ${response.requestOptions.uri}');
          debugPrint('STATUS: ${response.statusCode}');

          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('========== API ERROR ==========');
          debugPrint('URL: ${error.requestOptions.uri}');
          debugPrint('STATUS: ${error.response?.statusCode}');
          debugPrint('MESSAGE: ${error.message}');

          handler.next(error);
        },
      ),
    );
  }
}
