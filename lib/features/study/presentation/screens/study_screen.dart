
import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 60,
          ),
          SizedBox(height: 16),
          Text(
            'Your study materials will appear here',
          ),
        ],
      ),
    );
  }
}
