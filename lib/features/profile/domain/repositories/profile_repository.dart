import 'package:chat_flutter_poc/features/authentication/data/models/auth_user_model.dart';

abstract class ProfileRepository {
  Future<AuthUserModel> updateProfile({
    required String displayName,
    required String about,
  });
}