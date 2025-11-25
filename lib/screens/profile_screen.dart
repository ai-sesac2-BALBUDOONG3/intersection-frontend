import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/screens/edit_profile_screen.dart';
import 'package:intersection/screens/landing_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppState.currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ----------------------------------------------------
          // 유저 정보
          // ----------------------------------------------------
          if (user != null) ...[
            Text("이름: ${user.name}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("지역: ${user.region}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("학교: ${user.school}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("입학년도: ${user.birthYear}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
          ],

          // ----------------------------------------------------
          // 프로필 수정
          // ----------------------------------------------------
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
              child: const Text(
                "프로필 수정",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const Spacer(),

          // ----------------------------------------------------
          // 로그아웃
          // ----------------------------------------------------
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await AppState.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "로그아웃",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
