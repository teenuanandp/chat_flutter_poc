import 'package:chat_flutter_poc/core/realtime/signalr_service.dart';
import 'package:chat_flutter_poc/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chat_flutter_poc/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chat_flutter_poc/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_flutter_poc/features/chat/presentation/cubit/chat_messages_cubit.dart';
import 'package:chat_flutter_poc/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:chat_flutter_poc/features/profile/domain/repositories/profile_repository.dart';
import 'package:chat_flutter_poc/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';

import 'package:chat_flutter_poc/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:chat_flutter_poc/features/authentication/presentation/cubit/login_cubit.dart';

// Profile DI
import 'package:chat_flutter_poc/features/profile/data/storage/profile_local_storage.dart';
import 'package:chat_flutter_poc/features/profile/data/datasources/profile_remote_data_source.dart';

// Chat List
import 'package:chat_flutter_poc/features/chat_list/data/datasources/conversation_remote_data_source.dart';
import 'package:chat_flutter_poc/features/chat_list/data/repositories/conversation_repository_impl.dart';
import 'package:chat_flutter_poc/features/chat_list/domain/repositories/conversation_repository.dart';
import 'package:chat_flutter_poc/features/chat_list/presentation/cubit/conversation_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Secure storage
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // Dio clients
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(secureStorage: getIt<SecureStorageService>()),
  );

  // A new Cubit for each Login screen
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );

  // Profile API
  getIt.registerLazySingleton<ProfileLocalStorage>(() => ProfileLocalStorage());

  // Profile Update
  // Data sources
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
    ),
  );

  // Use case
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(
      repository: getIt<ProfileRepository>(),
      localStorage: getIt<ProfileLocalStorage>(),
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

  // Conversation API
  getIt.registerLazySingleton<ConversationRemoteDataSource>(
    () => ConversationRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Conversation Repository
  getIt.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(
      remoteDataSource: getIt<ConversationRemoteDataSource>(),
    ),
  );

  // Conversation Cubit
  getIt.registerFactory<ConversationCubit>(
    () => ConversationCubit(repository: getIt<ConversationRepository>()),
  );

  // Chat module

  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: getIt<ChatRemoteDataSource>()),
  );

  getIt.registerFactory<ChatMessagesCubit>(
    () => ChatMessagesCubit(
      repository: getIt<ChatRepository>(),
      signalRService: getIt<SignalRService>(),
    ),
  );

  // SignalR Service
  getIt.registerLazySingleton<SignalRService>(
    () => SignalRService(secureStorage: getIt<SecureStorageService>()),
  );
}
