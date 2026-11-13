
import 'package:flutter/material.dart';

import 'package:chat_flutter_poc/core/di/injection_container.dart';
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
    _checkSession();
  }

  void _checkSession() {
    _sessionFuture = getIt<AuthRemoteDataSource>().restoreSession();
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
                  const Text(
                    'Unable to connect. Please check your internet connection.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(_checkSession);
                    },
                    child: const Text('Try again'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                      );
                    },
                    child: const Text('Continue to login'),
                  ),
                ],
              ),
            ),
          );
        }

        final session = snapshot.data;

        if (session == null) {
          return const WelcomeScreen();
        }

        return HomeScreen(
          displayName: session.user.displayName,
          email: session.user.email,
        );
      },
    );
  }
}