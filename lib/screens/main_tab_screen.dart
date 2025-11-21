import 'package:flutter/material.dart';
import 'package:intersection/screens/recommended_friends_screen.dart';
import 'package:intersection/screens/friends_screen.dart';
import 'package:intersection/screens/community_screen.dart';

class MainTabScreen extends StatefulWidget {
  final int initialIndex;
  const MainTabScreen({super.key, this.initialIndex = 1});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  late int _currentIndex = widget.initialIndex;

  final _screens = const [
    FriendsScreen(),              // ← 친구 목록을 첫 번째 탭으로
    RecommendedFriendsScreen(),   // ← 추천 친구
    CommunityScreen(),            // ← 커뮤니티
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: '친구목록',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_search_outlined),
            selectedIcon: Icon(Icons.person_search),
            label: '추천친구',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
        ],
      ),
    );
  }
}
