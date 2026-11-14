
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../storage/secure_storage_service.dart';
import '../network/api_endpoints.dart';

class SignalRService {
  final SecureStorageService secureStorage;

  HubConnection? _connection;

  SignalRService({
    required this.secureStorage,
  });

  Future<void> connect() async {
    if (isConnected) return;

    final accessToken =
        await secureStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Authentication token unavailable.');
    }

    final options = HttpConnectionOptions(
      accessTokenFactory: () async {
        // Read the latest token, including after rotation.
        final token = await secureStorage.getAccessToken();

        if (token == null || token.isEmpty) {
          throw Exception('Authentication token unavailable.');
        }

        return token;
      },
    );

    _connection = HubConnectionBuilder()
        .withUrl(
          ApiEndpoints.chatHubUrl,
          options: options,
        )
        .withAutomaticReconnect()
        .build();

    // Register connection lifecycle handlers here.
    _connection!.onclose(({error}) {
      debugPrint('SignalR disconnected: $error');
    });

    _connection!.onreconnecting(({error}) {
      debugPrint('SignalR reconnecting: $error');
    });

    _connection!.onreconnected(({connectionId}) {
      debugPrint(
        'SignalR reconnected: $connectionId',
      );
    });

    await _connection!.start();

    debugPrint('SignalR connected successfully.');
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;
}
