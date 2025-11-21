import 'package:flutter/material.dart';
import 'package:intersection/models/user.dart';

class FriendProfileScreen extends StatelessWidget {
  final User user;

  const FriendProfileScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================
            // 1) 상단 커버 + 프로필 아바타
            // ==========================
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 커버 영역
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1a1a1a),
                        Color(0xFF444444),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // 프로필 동그라미
                Positioned(
                  left: 24,
                  bottom: -40,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 56),

            // ==========================
            // 2) 기본 정보 (이름, 한 줄 설명)
            // ==========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${user.birthYear}년생 · ${user.school} · ${user.region}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            // TODO: 채팅 화면 연결 (지금은 UI만)
                          },
                          child: const Text('채팅하기'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================
            // 3) 기본 정보 카드들 (지역 / 학교 / 출생연도)
            // ==========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _infoCard(
                    label: '지역',
                    value: user.region,
                  ),
                  const SizedBox(height: 8),
                  _infoCard(
                    label: '학교',
                    value: user.school,
                  ),
                  const SizedBox(height: 8),
                  _infoCard(
                    label: '출생연도',
                    value: '${user.birthYear}년',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================
            // 4) 공통 추억 / 키워드 섹션 (지금은 더미)
            // ==========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '공통 추억 키워드',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _KeywordChip(label: '매점 떡볶이'),
                      _KeywordChip(label: '체육대회'),
                      _KeywordChip(label: '98년생'),
                      _KeywordChip(label: '운동장 농구'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================
            // 5) 최근 활동 (더미 리스트)
            // ==========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '최근 활동',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _activityCard(
                    title: '“초5 때 운동장에서 놀던 멤버 찾습니다”',
                    subtitle: '${user.school} · ${user.region}',
                    time: '3시간 전',
                  ),
                  const SizedBox(height: 8),
                  _activityCard(
                    title: '“매점에서 맨날 같이 먹던 친구 기억나?”',
                    subtitle: '추억 커뮤니티 글',
                    time: '어제',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard({
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;

  const _KeywordChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '# $label',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF555555),
        ),
      ),
    );
  }
}
