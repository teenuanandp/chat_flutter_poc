import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {'UserNameOrEmail': email, 'password': password},
    );

    return Map<String, dynamic>.from(response.data);
  }
}
