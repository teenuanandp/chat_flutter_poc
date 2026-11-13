
import 'package:flutter/material.dart';

import 'package:chat_flutter_poc/core/shared/widgets/avatar/app_avatar.dart';

class AvatarPreviewScreen extends StatelessWidget {
  final String name;

  const AvatarPreviewScreen({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: AppAvatar(
          displayName: name,
          size: 240,
        ),
      ),
    );
  }
}
