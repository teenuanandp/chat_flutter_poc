
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:chat_flutter_poc/core/di/injection_container.dart';
import 'package:chat_flutter_poc/core/realtime/signalr_service.dart';
import 'package:chat_flutter_poc/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:chat_flutter_poc/features/authentication/data/models/auth_session_model.dart';
import 'package:chat_flutter_poc/features/authentication/presentation/screens/welcome_screen.dart';
import 'package:chat_flutter_poc/features/home/presentation/screens/home_screen.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late Future<AuthSession?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  void _restoreSession() {
    _sessionFuture = _restoreSessionAndConnect();
  }

  Future<AuthSession?> _restoreSessionAndConnect() async {
    // First restore the user's session and refresh tokens.
    final session = await getIt<AuthRemoteDataSource>().restoreSession();

    if (session != null) {
      // Start SignalR without blocking the Home screen.
      unawaited(_connectSignalR());
    }

    return session;
  }

  Future<void> _connectSignalR() async {
    try {
      debugPrint('Starting SignalR connection after session restore...');
      await getIt<SignalRService>().connect();
      debugPrint('SignalR is ready.');
    } catch (error, stackTrace) {
      // Realtime failure should not prevent the user from opening the app.
      debugPrint('SignalR connection failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthSession?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to restore your session.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(_restoreSession);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.data != null) {
          return const HomeScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}
