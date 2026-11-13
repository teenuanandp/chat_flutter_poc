
class LoginRequest {
  final String userNameOrEmail;
  final String password;
  final String deviceInfo;

  const LoginRequest({
    required this.userNameOrEmail,
    required this.password,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'userNameOrEmail': userNameOrEmail,
      'password': password,
      'deviceInfo': deviceInfo,
    };
  }
}

class RefreshRequest {
  final String refreshToken;

  const RefreshRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

class LogoutRequest {
  final String refreshToken;
  final bool allDevices;

  const LogoutRequest({
    required this.refreshToken,
    this.allDevices = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
      'allDevices': allDevices,
    };
  }
}
