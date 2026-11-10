import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/auth_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/chats/data/services/chat_service.dart';
import '../../features/chats/presentation/providers/chat_provider.dart';
import '../../features/chats/presentation/cubit/chat_cubit.dart';


import '../network/dio_client.dart';
import '../network/token_store.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<TokenStore>(
    () => TokenStore(),
  );

  getIt.registerLazySingleton<Dio>(
    () => DioClient.create(getIt<TokenStore>()),
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<Dio>()),
  );

  getIt.registerFactory<AuthProvider>(
    () => AuthProvider(
      getIt<AuthService>(),
      getIt<TokenStore>(),
    ),
  );

  getIt.registerLazySingleton<ChatService>(
    () => ChatService(getIt<Dio>()),
  );

  getIt.registerFactory<ChatProvider>(
    () => ChatProvider(getIt<ChatService>()),
  );

  getIt.registerFactory<ChatCubit>(
  () => ChatCubit(getIt<ChatService>()),
);
}