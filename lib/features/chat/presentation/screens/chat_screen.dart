
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 60,
          ),
          SizedBox(height: 16),
          Text(
            'Your conversations will appear here',
          ),
        ],
      ),
    );
  }
}
