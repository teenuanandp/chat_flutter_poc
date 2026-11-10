import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  final String chatName;

  const ChatDetailScreen({super.key, required this.chatName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(chatName)),
      body: const Center(
        child: Text('Chat Detail Screen - Next Implementation'),
      ),
    );
  }
}
