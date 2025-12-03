// lib/data/user_storage.dart

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';

/// JWT / 유저정보 로컬(보안 저장소) 관리
class UserStorage {
  UserStorage._internal();

  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  // 저장 키
  static const String _keyToken = 'intersection_token';
  static const String _keyUser = 'intersection_user';

  // ==========================
  // 1) 토큰
  // ==========================

  /// JWT 토큰 저장
  static Future<void> saveToken(String token) async {
    await _secure.write(key: _keyToken, value: token);
  }

  /// JWT 토큰 로드 (없으면 null)
  static Future<String?> loadToken() async {
    return await _secure.read(key: _keyToken);
  }

  /// JWT 토큰 삭제
  static Future<void> clearToken() async {
    await _secure.delete(key: _keyToken);
  }

  // ==========================
  // 2) 유저 정보
  // ==========================

  /// 유저 정보 저장
  static Future<void> saveUser(User user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _secure.write(key: _keyUser, value: jsonStr);
  }

  /// 유저 정보 로드 (없으면 null)
  static Future<User?> loadUser() async {
    final jsonStr = await _secure.read(key: _keyUser);
    if (jsonStr == null) return null;

    try {
      final map = jsonDecode(jsonStr);
      return User.fromJson(map as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// 유저 정보 삭제
  static Future<void> clearUser() async {
    await _secure.delete(key: _keyUser);
  }

  // ==========================
  // 3) 전체 삭제 (로그아웃 등)
  // ==========================
  static Future<void> clearAll() async {
    await _secure.delete(key: _keyToken);
    await _secure.delete(key: _keyUser);
  }
}
