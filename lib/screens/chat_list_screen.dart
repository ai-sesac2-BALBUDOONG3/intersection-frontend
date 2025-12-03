// lib/screens/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/models/user.dart';
import 'package:intersection/screens/chat_screen.dart';

/// 내가 채팅을 시작한 친구들을 모아서 보여주는 화면
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ids = AppState.chatList.toSet().toList();      // 중복 제거
    final friends = AppState.friends;

    // chatList 에 있는 id 중, 실제 친구 목록에 존재하는 유저만 보여줌
    final List<User> chatFriends = friends
        .where((u) => ids.contains(u.id))
        .toList();

    if (chatFriends.isEmpty) {
      return Center(
        child: Text(
          '아직 채팅중인 친구가 없어요.\n친구 목록에서 먼저 말을 걸어보세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final f = chatFriends[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(
            f.name,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            [
              if (f.school.isNotEmpty) f.school,
              if (f.region.isNotEmpty) f.region,
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(friend: f),
              ),
            );
          },
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: chatFriends.length,
    );
  }
}
