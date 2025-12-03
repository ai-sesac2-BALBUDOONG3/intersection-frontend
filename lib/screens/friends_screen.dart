// lib/screens/friends_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/models/user.dart';
import 'package:intersection/screens/chat_screen.dart';
import 'package:intersection/screens/friend_profile_screen.dart';

/// 친구 목록 + 내 프로필 화면
/// - 현재는 AppState.friends 기반
/// - 나중에 /friends API 연동 시 _loadFriends() 안만 교체하면 됨
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  bool _isLoading = true;
  bool _friendsExpanded = true;
  String? _errorMessage;

  // 로컬 상태로도 들고 있게 (AppState.friends와 분리)
  List<User> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: 실제 백엔드 붙일 때 여기서 ApiService().get('/friends') 등으로 교체
      // 지금은 AppState.friends 가 이미 어딘가에서 채워졌다고 가정
      _friends = List<User>.from(AppState.friends);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('친구 목록 불러오기 오류: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '친구 목록을 불러오지 못했습니다.\n잠시 후 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AppState.currentUser;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadFriends,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMyProfile(currentUser),
          const SizedBox(height: 20),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          GestureDetector(
            onTap: () {
              setState(() {
                _friendsExpanded = !_friendsExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  '친구 ${_friends.length}',
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

          if (_friends.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  '아직 등록된 친구가 없어요.\n추천 친구 탭에서 먼저 친구를 만들어볼까요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else if (_friendsExpanded)
            ..._friends.map((user) => _buildFriendTile(user)),
        ],
      ),
    );
  }

  Widget _buildMyProfile(User? user) {
    if (user == null) {
      return Card(
        elevation: 0,
        color: Colors.grey[50],
        child: const ListTile(
          leading: CircleAvatar(
            radius: 26,
            child: Icon(Icons.person_outline),
          ),
          title: Text(
            '내 프로필 정보가 없습니다',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '회원가입 후 자동으로 프로필이 생성됩니다.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    }

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
        subtitle: Text(
          [
            if (user.school.isNotEmpty) user.school,
            if (user.region.isNotEmpty) user.region,
          ].join(' · '),
        ),
        trailing: const Icon(Icons.edit, size: 20),
        onTap: () {
          // TODO: 내 프로필 편집 화면 연결 예정
        },
      ),
    );
  }

  Widget _buildFriendTile(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
        subtitle: Text(
          [
            if (user.school.isNotEmpty) user.school,
            if (user.region.isNotEmpty) user.region,
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
