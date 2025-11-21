import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/models/user.dart';
import 'package:intersection/screens/friend_profile_screen.dart';

class RecommendedFriendsScreen extends StatefulWidget {
  const RecommendedFriendsScreen({super.key});

  @override
  State<RecommendedFriendsScreen> createState() => _RecommendedFriendsScreenState();
}

class _RecommendedFriendsScreenState extends State<RecommendedFriendsScreen> {
  @override
  Widget build(BuildContext context) {
    final recommendedFriends = AppState.recommendedFriends;  
    final currentFriends = AppState.friends;               

    return Scaffold(
      appBar: AppBar(
        title: const Text('추천친구'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '당신과 지역·학교·나이가 유사한 친구들을 추천해요',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // 추천 친구 리스트
          ...recommendedFriends.map((user) {
            final isFriendAlready = currentFriends.any((f) => f.id == user.id);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  child: user.profileImageUrl == null
                      ? const Icon(Icons.person)
                      : ClipOval(
                          child: Image.network(
                            user.profileImageUrl!,
                            fit: BoxFit.cover,
                            width: 48,
                            height: 48,
                          ),
                        ),
                ),

                title: Text(user.name),
                subtitle: Text('${user.school} · ${user.region}'),

                // 프로필 화면 이동
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FriendProfileScreen(user: user),
                    ),
                  );
                },

                trailing: isFriendAlready
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 22,
                      )
                    : FilledButton(
                        onPressed: () {
                          setState(() {
                            AppState.follow(user);
                          });
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: const Text('추가'),
                      ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
