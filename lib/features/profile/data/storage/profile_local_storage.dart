
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../authentication/data/models/auth_user_model.dart';

class ProfileLocalStorage {
  static const String _profileKey = 'cached_user_profile';

  Future<void> saveProfile(AuthUserModel profile) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _profileKey,
      jsonEncode(profile.toJson()),
    );
  }

  Future<AuthUserModel?> getProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final profileJson = preferences.getString(_profileKey);

    if (profileJson == null || profileJson.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(profileJson) as Map<String, dynamic>;
      return AuthUserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearProfile() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_profileKey);
  }
}
