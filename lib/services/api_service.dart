// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../data/app_state.dart';

class ApiService {
  // ----------------------------------------------------
  // 공통 헤더 (토큰 포함)
  // ----------------------------------------------------
  static Map<String, String> _headers({bool json = true}) {
    final token = AppState.token;
    return {
      if (json) "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ----------------------------------------------------
  // 1) 회원가입
  // ----------------------------------------------------
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/users/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("회원가입 실패: ${response.body}");
    }
  }

  // ----------------------------------------------------
  // 2) 로그인
  // ----------------------------------------------------
  static Future<String> login(String email, String password) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/token");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["access_token"];
    } else {
      throw Exception("로그인 실패: ${response.body}");
    }
  }

  // ----------------------------------------------------
  // 3) 내 정보 가져오기 (전체 User 모델 자동 매핑)
  // ----------------------------------------------------
  static Future<User> getMyInfo() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/users/me");
    final response = await http.get(url, headers: _headers(json: false));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);  // 🔥 전체 필드 반영
    } else {
      throw Exception("내 정보 불러오기 실패: ${response.body}");
    }
  }

  // ----------------------------------------------------
  // 4) 추천 친구 목록
  // ----------------------------------------------------
  static Future<List<User>> getRecommendedFriends() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/users/me/recommended");

    final response = await http.get(url, headers: _headers(json: false));

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception("추천 친구 불러오기 실패: ${response.body}");
    }
  }

  // ----------------------------------------------------
  // 5) 친구 추가
  // ----------------------------------------------------
  static Future<bool> addFriend(int targetUserId) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/friends/$targetUserId");
    final response = await http.post(url, headers: _headers(json: false));
    return response.statusCode == 200;
  }

  // ----------------------------------------------------
  // 6) 친구 목록
  // ----------------------------------------------------
  static Future<List<User>> getFriends() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/friends/me");

    final response = await http.get(url, headers: _headers(json: false));

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception("친구 목록 불러오기 실패: ${response.body}");
    }
  }

  // ----------------------------------------------------
  // 7) 🔥 프로필 이미지 업로드
  // ----------------------------------------------------
  static Future<String> uploadProfileImage(String filePath) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/upload/profile");

    final req = http.MultipartRequest("POST", url);
    req.headers["Authorization"] = "Bearer ${AppState.token}";
    req.files.add(await http.MultipartFile.fromPath("file", filePath));

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode == 200) {
      final data = jsonDecode(body);
      return data["url"]; // 서버에서 제공하는 이미지 URL
    } else {
      throw Exception("프로필 이미지 업로드 실패: $body");
    }
  }

  // ----------------------------------------------------
  // 8) 🔥 배경 이미지 업로드
  // ----------------------------------------------------
  static Future<String> uploadBackgroundImage(String filePath) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/upload/background");

    final req = http.MultipartRequest("POST", url);
    req.headers["Authorization"] = "Bearer ${AppState.token}";
    req.files.add(await http.MultipartFile.fromPath("file", filePath));

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode == 200) {
      final data = jsonDecode(body);
      return data["url"];
    } else {
      throw Exception("배경 이미지 업로드 실패: $body");
    }
  }

  // ----------------------------------------------------
  // 9) 🔥 피드 이미지 업로드
  // ----------------------------------------------------
  static Future<String> uploadFeedImage(String filePath) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/upload/feed");

    final req = http.MultipartRequest("POST", url);
    req.headers["Authorization"] = "Bearer ${AppState.token}";
    req.files.add(await http.MultipartFile.fromPath("file", filePath));

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode == 200) {
      final data = jsonDecode(body);
      return data["url"];
    } else {
      throw Exception("피드 이미지 업로드 실패: $body");
    }
  }
}
