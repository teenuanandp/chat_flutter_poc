class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://studycircle.runasp.net';

  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';

  // Users
  static const String myProfile = '/api/users/me';

  // Chat List (Conversations)
  static const String conversations = '/api/conversations';
  static String conversationMessages(String id) =>
      '/api/conversations/$id/messages';

  // SignalR
  static const String chatHub = '/hubs/chat';

  static String get chatHubUrl => '$baseUrl$chatHub';
}
