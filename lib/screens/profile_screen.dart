// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/data/user_storage.dart';
import 'package:intersection/screens/landing_screen.dart';
import 'package:intersection/services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    await UserStorage.clearAll();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_outlined, size: 40),
              const SizedBox(height: 12),
              const Text('로그인된 계정이 없습니다.'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LandingScreen()),
                    (route) => false,
                  );
                },
                child: const Text('시작 화면으로 이동'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              '내 정보',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Card(
              elevation: 0,
              color: Colors.grey[50],
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 26,
                  child: Icon(Icons.person),
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  [
                    if (user.school.isNotEmpty) user.school,
                    if (user.region.isNotEmpty) user.region,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              '기본 정보',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // 🔥 여기만 수정: loginId 대신 id 사용
            _infoRow('회원 번호', '#${user.id}'),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            const Text(
              '계정 관리',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
                onPressed: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
