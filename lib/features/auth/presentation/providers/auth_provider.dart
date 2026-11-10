import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../../../core/network/token_store.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenStore _tokenStore;
  AuthProvider(this._authService, this._tokenStore);

  bool isLoading = false;
  String? errorMessage;

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
       final result = await _authService.login(email: email, password: password);

      final responseData = result['data'] is Map
          ? Map<String, dynamic>.from(result['data'])
          : result;

      final token = responseData['accessToken']?.toString();

      if (token == null || token.isEmpty) {
        throw Exception('Access token missing from login response.');
      }

      _tokenStore.saveAccessToken(token);

      return true;
    } catch (e) {
      errorMessage = 'Login failed. Please try again.';

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
