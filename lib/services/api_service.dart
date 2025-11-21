import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // --------------------
  // 1) 회원가입
  // --------------------
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

  // --------------------
  // 2) 로그인 API
  // --------------------
  static Future<String> login(String email, String password) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/token");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "username": email,
        "password": password,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data["access_token"]; // JWT
    } else {
      throw Exception("로그인 실패: ${response.body}");
    }
  }
}
