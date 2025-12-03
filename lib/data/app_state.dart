// lib/data/app_state.dart

import 'package:intersection/models/user.dart';

class AppState {
  /// JWT 토큰
  static String? token;

  /// 현재 로그인한 유저 (백엔드 /me 같은 API로 채워질 예정)
  static User? currentUser;

  /// 내 친구 목록 (FriendsScreen에서 채움)
  static List<User> friends = [];

  /// 채팅 중인 친구의 userId 목록 (ChatScreen에서 채움)
  static List<int> chatList = [];

  /// 로그아웃/토큰 만료 시 한 번에 초기화
  static void clear() {
    token = null;
    currentUser = null;
    friends = [];
    chatList = [];
  }
}
