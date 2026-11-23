// ignore_for_file: unused_element, unused_field,unused_local_variable

import 'package:flutter/material.dart';
import 'package:chat_flutter_poc/core/shared/widgets/feedback/app_shimmer.dart';

class ChatListShimmer extends StatelessWidget {
  final int itemCount;

  const ChatListShimmer({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        return const _ChatListShimmerItem();
      },
    );
  }
}

class _ChatListShimmerItem extends StatelessWidget {
  const _ChatListShimmerItem();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      child: Row(
        children: [
          // Avatar
          const AppShimmerBox(
            width: 48,
            height: 48,
            isCircle: true,
          ),

          const SizedBox(width: 12),

          // Name and last message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppShimmerBox(
                  width: 135,
                  height: 14,
                  radius: 4,
                ),
                const SizedBox(height: 9),
                const AppShimmerBox(
                  width: 190,
                  height: 11,
                  radius: 4,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Time placeholder
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const AppShimmerBox(
                width: 35,
                height: 10,
                radius: 4,
              ),
              const SizedBox(height: 10),
              AppShimmerBox(
                width: 18,
                height: 18,
                radius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
