import 'package:chat_flutter_poc/features/authentication/data/models/auth_user_model.dart';

import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<AuthUserModel> updateProfile({
    required String displayName,
    required String about,
  }) {
    return remoteDataSource.updateMyProfile(
      displayName: displayName,
      about: about,
    );
  }
}