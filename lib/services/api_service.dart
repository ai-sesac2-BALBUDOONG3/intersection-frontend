import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intersection/config/api_config.dart';
import 'package:intersection/models/user.dart';

class ApiService {
  ApiService._();

  /// 공통 JSON 헤더
  static Map<String, String> _jsonHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// 로그인 → access_token 반환
  ///
  /// - [loginId]: 서버의 login_id 필드에 매핑
  /// - [password]: 평문 비밀번호
  static Future<String> login(String loginId, String password) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode({
        'login_id': loginId,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      String message = '로그인에 실패했습니다. (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['detail'] != null) {
          message = body['detail'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('토큰이 응답에 없습니다.');
    }

    return token;
  }

  /// 로그인 후 내 정보 조회
  ///
  /// - [token]: login()에서 받은 access_token
  static Future<User> getMyInfo(String token) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/me');

    final response = await http.get(
      uri,
      headers: _jsonHeaders(token: token),
    );

    if (response.statusCode != 200) {
      String message = '내 정보 조회에 실패했습니다. (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['detail'] != null) {
          message = body['detail'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return User.fromJson(body);
  }

  /// 회원가입 요청
  ///
  /// 사용 예:
  /// final user = await ApiService.register(
  ///   loginId: 'test123',
  ///   password: 'pw1234!',
  ///   realName: '홍길동',
  ///   nickname: '길동이',
  ///   email: 'test@example.com',
  /// );
  static Future<User> register({
    required String loginId,
    required String password,
    required String realName,
    required String nickname,
    String? email,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/register');

    final response = await http.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode({
        'login_id': loginId,
        'password': password,
        'real_name': realName,
        'nickname': nickname,
        'email': email,
      }),
    );

    if (response.statusCode != 201) {
      String message = '회원가입에 실패했습니다. (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['detail'] != null) {
          message = body['detail'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return User.fromJson(body);
  }
}
