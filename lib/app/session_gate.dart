import 'package:flutter/material.dart';
import 'package:chat_flutter_poc/core/di/injection_container.dart';
import 'package:chat_flutter_poc/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:chat_flutter_poc/features/authentication/presentation/screens/welcome_screen.dart';

// Import your actual HomeScreen path.
import 'package:chat_flutter_poc/features/home/presentation/screens/home_screen.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late Future _sessionFuture;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  void _restoreSession() {
    _sessionFuture = getIt<AuthRemoteDataSource>().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _sessionFuture,
      builder: (context, snapshot) {

        // Checking existing session.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Network/server error.
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
                      setState(() {
                        _restoreSession();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Session restored successfully.
        if (snapshot.data != null) {
          return const HomeScreen();
        }

        // No valid session.
        return const WelcomeScreen();
      },
    );
  }
}