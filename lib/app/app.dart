import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../core/di/injection.dart';
import '../features/chats/presentation/providers/chat_provider.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<ChatProvider>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inaippu',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
