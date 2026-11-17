import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../features/chat/data/models/message_model.dart';
import '../network/api_endpoints.dart';
import '../storage/secure_storage_service.dart';

class SignalRService {
  final SecureStorageService secureStorage;

  HubConnection? _connection;
  bool _isConnecting = false;

  final StreamController<TypingEvent> _typingController =
      StreamController<TypingEvent>.broadcast();

  Stream<TypingEvent> get typingEvents => _typingController.stream;

  // Broadcast channel for incoming chat messages.
  final StreamController<MessageModel> _messageController =
      StreamController<MessageModel>.broadcast();

  Stream<MessageModel> get incomingMessages => _messageController.stream;

  SignalRService({required this.secureStorage});

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  Future<void> connect() async {
    if (isConnected || _isConnecting) {
      debugPrint('SignalR already connected or connecting.');
      return;
    }

    _isConnecting = true;

    try {
      final accessToken = await secureStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token not available.');
      }

      final options = HttpConnectionOptions(
        accessTokenFactory: () async {
          final token = await secureStorage.getAccessToken();

          if (token == null || token.isEmpty) {
            throw Exception('Access token unavailable.');
          }

          return token;
        },
      );

      _connection = HubConnectionBuilder()
          .withUrl(ApiEndpoints.chatHubUrl, options: options)
          .withAutomaticReconnect(
            retryDelays: [0, 1000, 2000, 5000, 10000, 20000],
          )
          .build();

      _connection!.serverTimeoutInMilliseconds = 60000;

      _registerConnectionEvents();

      // Register handlers BEFORE starting the connection.
      _registerMessageEvents();

      _connection!.on('TypingStarted', (arguments) {
        _handleTypingEvent(arguments, isTyping: true);
      });

      _connection!.on('TypingStopped', (arguments) {
        _handleTypingEvent(arguments, isTyping: false);
      });

      await _connection!.start();

      debugPrint('SIGNALR CONNECTED: ${_connection!.connectionId}');
    } catch (error, stackTrace) {
      debugPrint('SIGNALR CONNECTION FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  void _registerConnectionEvents() {
    _connection!.onreconnecting(({error}) {
      debugPrint('SIGNALR RECONNECTING: $error');
    });

    _connection!.onreconnected(({connectionId}) {
      debugPrint('SIGNALR RECONNECTED: $connectionId');
    });

    _connection!.onclose(({error}) {
      debugPrint('SIGNALR CONNECTION CLOSED: $error');
    });
  }

  void _registerMessageEvents() {
    _connection!.on('ReceiveMessage', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) {
          debugPrint('ReceiveMessage: empty payload.');
          return;
        }

        final rawMessage = arguments[0];

        if (rawMessage is! Map) {
          debugPrint('ReceiveMessage: unexpected payload type.');
          return;
        }

        final json = Map<String, dynamic>.from(rawMessage);

        final message = MessageModel.fromJson(json);

        debugPrint('SIGNALR MESSAGE RECEIVED: ${message.id}');

        _messageController.add(message);
      } catch (error, stackTrace) {
        debugPrint('SIGNALR MESSAGE PARSING FAILED: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;

    debugPrint('SIGNALR DISCONNECTED');
  }

  void _handleTypingEvent(List<Object?>? arguments, {required bool isTyping}) {
    try {
      if (arguments == null || arguments.isEmpty) return;

      final rawEvent = arguments[0];

      if (rawEvent is! Map) return;

      final event = TypingEvent.fromJson(Map<String, dynamic>.from(rawEvent));

      debugPrint('SIGNALR TYPING: ${event.userId} - $isTyping');

      _typingController.add(event);
    } catch (error, stackTrace) {
      debugPrint('TYPING EVENT PARSING FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _generateMessageId() {
    final random = Random.secure();

    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // UUID v4 version and variant bits.
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  Future<void> typingStarted(String conversationId) async {
    if (!isConnected) return;

    await _connection!.invoke('TypingStarted', args: [conversationId]);
  }

  Future<void> typingStopped(String conversationId) async {
    if (!isConnected) return;

    await _connection!.invoke('TypingStopped', args: [conversationId]);
  }

  Future<MessageModel> sendTextMessage({
    required String conversationId,
    required String content,
  }) async {
    if (!isConnected) {
      throw Exception('SignalR is not connected.');
    }

    final messageId = _generateMessageId();

    final request = {
      'messageId': messageId,
      'conversationId': conversationId,
      'type': 'Text',
      'content': content,
      'replyToMessageId': null,
      'attachmentFileIds': null,
    };

    try {
      debugPrint('SIGNALR: Sending message $messageId');

      final result = await _connection!.invoke('SendMessage', args: [request]);

      if (result is! Map) {
        throw Exception('Invalid SendMessage acknowledgement.');
      }

      final acknowledgement = Map<String, dynamic>.from(result);

      final rawMessage = acknowledgement['message'];

      if (rawMessage is! Map) {
        throw Exception('Message missing from acknowledgement.');
      }

      final message = MessageModel.fromJson(
        Map<String, dynamic>.from(rawMessage),
      );

      debugPrint('SIGNALR: Message acknowledged: ${message.id}');
      debugPrint('SIGNALR: Duplicate: ${acknowledgement['duplicate']}');

      return message;
    } catch (error, stackTrace) {
      debugPrint('SIGNALR SEND FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}

class TypingEvent {
  final String conversationId;
  final String userId;

  const TypingEvent({required this.conversationId, required this.userId});

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    return TypingEvent(
      conversationId: json['conversationId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
    );
  }
}
