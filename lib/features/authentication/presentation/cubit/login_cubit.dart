
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/auth_requests.dart';
import '../../data/models/auth_user_model.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  failure,
}

class LoginState extends Equatable {
  final LoginStatus status;
  final AuthUserModel? user;
  final String? message;

  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.message,
  });

  @override
  List<Object?> get props => [status, user, message];
}

class LoginCubit extends Cubit<LoginState> {
  final AuthRemoteDataSource remoteDataSource;

  LoginCubit({
    required this.remoteDataSource,
  }) : super(const LoginState());

  Future<void> login({
    required String userNameOrEmail,
    required String password,
  }) async {
    emit(const LoginState(status: LoginStatus.loading));

    try {
      final session = await remoteDataSource.login(
        LoginRequest(
          userNameOrEmail: userNameOrEmail,
          password: password,
          deviceInfo: 'Flutter ${defaultTargetPlatform.name}',
        ),
      );

      emit(
        LoginState(
          status: LoginStatus.success,
          user: session.user,
          message: 'Signed in successfully',
        ),
      );
    } catch (error) {
      emit(
        LoginState(
          status: LoginStatus.failure,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
