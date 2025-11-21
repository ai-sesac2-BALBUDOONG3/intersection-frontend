import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/models/user.dart';
import 'package:intersection/screens/chat_screen.dart';
import 'package:intersection/screens/friend_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  bool _friendsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final friends = AppState.friends;
    final currentUser = AppState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 목록'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -----------------------------
          // 1. 내 프로필
          // -----------------------------
          _buildMyProfile(currentUser),

          const SizedBox(height: 20),

          // -----------------------------
          // 2. 친구 목록 (접힘/펼침)
          // -----------------------------
          GestureDetector(
            onTap: () {
              setState(() {
                _friendsExpanded = !_friendsExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  '친구 ${friends.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  _friendsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          if (_friendsExpanded)
            ...friends.map((user) => _buildFriendTile(user)).toList(),
        ],
      ),
    );
  }

  // -----------------------------
  // 내 프로필 블록
  // -----------------------------
  Widget _buildMyProfile(User? user) {
    if (user == null) return const SizedBox();

    return Card(
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        leading: const CircleAvatar(
          radius: 26,
          child: Icon(Icons.person),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${user.school} · ${user.region}'),
        trailing: const Icon(Icons.edit, size: 20),
      ),
    );
  }

  // -----------------------------
  // 친구 리스트 아이템
  // -----------------------------
  Widget _buildFriendTile(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Row(
          children: [
            Text(user.name),
            const SizedBox(width: 6),
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
        subtitle: Text('${user.school} · ${user.region}'),

        // 🔥 클릭 → 프로필 화면 이동
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FriendProfileScreen(user: user),
            ),
          );
        },

        trailing: OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(friend: user),
              ),
            );
          },
          child: const Text('채팅'),
        ),
      ),
    );
  }
}
