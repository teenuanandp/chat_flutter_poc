
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';

import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/presentation/cubit/login_cubit.dart';

// Profile DI
import '../../features/profile/data/storage/profile_local_storage.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Secure storage
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // Dio clients
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // A new Cubit for each Login screen
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );

  // Profile API
  getIt.registerLazySingleton<ProfileLocalStorage>(
    () => ProfileLocalStorage(),
  );

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(
      dioClient: getIt<DioClient>(),
    ),
  );

  // Authentication API
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      dioClient: getIt<DioClient>(),
      secureStorage: getIt<SecureStorageService>(),
      profileRemoteDataSource: getIt<ProfileRemoteDataSource>(),
      profileLocalStorage: getIt<ProfileLocalStorage>(),
    ),
  );
  
}
