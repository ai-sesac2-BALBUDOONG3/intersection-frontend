// lib/services/api_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../data/app_state.dart';
import '../data/user_storage.dart';
import '../models/user.dart';
import '../models/post.dart';

/// 공통 API 예외
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

/// Intersection 백엔드와 통신하는 공통 클라이언트
///
/// ⚠️ 사용 예:
///   await ApiService.login(loginId: 'test', password: '1234');
///   final me = await ApiService.getMyInfo();
///   final communities = await ApiService.getCommunities();
class ApiService {
  ApiService._internal();

  // 필요하면 나중에 인스턴스 방식으로 확장할 수 있게 기본 틀만 유지
  static final http.Client _client = http.Client();

  /// 기본 URL + path 로 URI 생성
  static Uri _uri(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  /// 공통 헤더 생성 (JWT 토큰 포함)
  static Future<Map<String, String>> _headers({bool json = true}) async {
    String? token = AppState.token;

    // 메모리에 없으면 storage 에서 한 번 로드
    if (token == null) {
      token = await UserStorage.loadToken();
      if (token != null && token.isNotEmpty) {
        AppState.token = token;
      }
    }

    final headers = <String, String>{
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// 공통 GET
  static Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _uri(path, queryParameters: queryParameters);
    final headers = await _headers();

    final response = await _client
        .get(uri, headers: headers)
        .timeout(ApiConfig.receiveTimeout);

    return _handleResponse(response);
  }

  /// 공통 POST (JSON body)
  static Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _uri(path, queryParameters: queryParameters);
    final headers = await _headers();

    final response = await _client
        .post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.receiveTimeout);

    return _handleResponse(response);
  }

  /// 공통 PATCH (JSON body)
  static Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _uri(path, queryParameters: queryParameters);
    // 🔥 여기 오타 있었음: __headers() → _headers()
    final headers = await _headers();

    final response = await _client
        .patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.receiveTimeout);

    return _handleResponse(response);
  }

  /// 공통 DELETE
  static Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _uri(path, queryParameters: queryParameters);
    final headers = await _headers();

    final response = await _client
        .delete(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.receiveTimeout);

    return _handleResponse(response);
  }

  /// 공통 응답 처리
  static dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    final body = response.body.isNotEmpty ? response.body : null;

    if (status >= 200 && status < 300) {
      if (body == null) return null;
      try {
        return jsonDecode(body);
      } catch (_) {
        // JSON이 아닌 경우(204 등) 그냥 body 문자열 리턴
        return body;
      }
    }

    String message = '요청에 실패했습니다. (status: $status)';

    if (body != null) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['detail'] != null) {
          message = decoded['detail'].toString();
        }
      } catch (_) {
        // ignore JSON parse error
      }
    }

    // 401인 경우 토큰 만료로 간주하고 메모리 상태 비움 (스토리지는 UI에서 정리)
    if (status == 401) {
      AppState.clear();
    }

    throw ApiException(message, statusCode: status);
  }

  // ==========================
  // 1) 인증 관련 메서드
  // ==========================

  /// 회원가입
  ///
  /// POST /auth/register
  /// body: {
  ///   "login_id": "...",
  ///   "password": "...",
  ///   "real_name": "...",
  ///   "nickname": "...",
  ///   "email": "..."
  /// }
  static Future<void> register({
    required String loginId,
    required String password,
    required String realName,
    required String nickname,
    required String email,
  }) async {
    final body = {
      'login_id': loginId,
      'password': password,
      'real_name': realName,
      'nickname': nickname,
      'email': email,
    };

    // 백엔드는 Token 을 돌려주지만 프론트는 지금은 결과만 확인
    await post('/auth/register', body: body);
  }

  /// 로그인
  ///
  /// POST /auth/login  (JSON body: { "login_id": "...", "password": "..." })
  static Future<void> login({
    required String loginId,
    required String password,
  }) async {
    final data = await post(
      '/auth/login',
      body: {
        'login_id': loginId,
        'password': password,
      },
    );

    Map<String, dynamic> map;
    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is Map) {
      map = Map<String, dynamic>.from(data as Map);
    } else {
      throw ApiException(
        '로그인 응답 형식이 올바르지 않습니다.',
        statusCode: null,
      );
    }

    final token = map['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException(
        '토큰이 응답에 없습니다.',
        statusCode: null,
      );
    }

    // 메모리 & 스토리지에 저장
    AppState.token = token;
    await UserStorage.saveToken(token);

    // 선택: 내 정보도 바로 동기화
    try {
      final me = await getMyInfo();
      AppState.currentUser = me;
      await UserStorage.saveUser(me);
    } catch (_) {
      // /users/me 가 아직 준비 안됐으면 그냥 무시
    }
  }

  /// 내 정보 조회 (/users/me)
  static Future<User> getMyInfo() async {
    final data = await get('/users/me');

    if (data is Map<String, dynamic>) {
      return User.fromJson(data);
    }
    if (data is Map) {
      return User.fromJson(Map<String, dynamic>.from(data as Map));
    }

    throw ApiException('잘못된 사용자 정보 응답 형식입니다.');
  }

  /// 로그아웃 (클라이언트 기준)
  static Future<void> logout() async {
    AppState.clear();
    await UserStorage.clearAll();
  }

  // ==========================
  // 2) 온보딩 / 매칭 / 추천
  // ==========================

  /// 온보딩 POST /match/onboarding
  static Future<dynamic> onboarding(Map<String, dynamic> body) async {
    return post('/match/onboarding', body: body);
  }

  /// 추천친구 GET /match/recommendations
  ///
  /// 백엔드 응답이
  ///  - [ {...}, {...} ]
  ///  - { "items": [ {...}, ... ] }
  /// 둘 중 무엇이든 대응하도록 구현
  static Future<dynamic> fetchRecommendationsRaw({
    int limit = 20,
    bool withReasons = true,
  }) async {
    return get('/match/recommendations', queryParameters: {
      'limit': limit,
      'with_reasons': withReasons,
    });
  }

  /// User 리스트로 파싱된 추천친구
  static Future<List<User>> getRecommendedFriends({
    int limit = 20,
    bool withReasons = true,
  }) async {
    final data = await fetchRecommendationsRaw(
      limit: limit,
      withReasons: withReasons,
    );

    List<dynamic> items;

    if (data is List) {
      items = data;
    } else if (data is Map && data['items'] is List) {
      items = List<dynamic>.from(data['items'] as List);
    } else {
      return [];
    }

    return items
        .where((e) => e is Map)
        .map((e) => User.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ==========================
  // 3) 친구 관련 메서드 (간단 버전)
  // ==========================

  /// 친구 목록 GET /friends
  static Future<List<User>> getFriends() async {
    final data = await get('/friends');

    if (data is List) {
      return data
          .where((e) => e is Map)
          .map((e) => User.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    if (data is Map && data['items'] is List) {
      final list = data['items'] as List;
      return list
          .where((e) => e is Map)
          .map((e) => User.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return [];
  }

  /// 친구 추가 (또는 친구 요청) POST /friends/requests/{target_user_id}
  ///
  /// 백엔드에서 실제로는 "요청" 개념일 수 있지만,
  /// 프론트 기준으로는 "친구 추가 버튼" 행동에 대응.
  static Future<bool> addFriend(int targetUserId) async {
    await post('/friends/requests/$targetUserId');
    return true;
  }

  // ==========================
  // 4) 커뮤니티 / 게시글 / 댓글
  // ==========================

  /// 커뮤니티 목록 GET /communities
  static Future<List<Community>> getCommunities() async {
    final data = await get('/communities');

    List<dynamic> items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['items'] is List) {
      items = List<dynamic>.from(data['items'] as List);
    } else {
      return [];
    }

    return items
        .where((e) => e is Map)
        .map((e) => Community.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// 커뮤니티 상세 GET /communities/{id}
  static Future<Community> getCommunityDetail(int communityId) async {
    final data = await get('/communities/$communityId');

    if (data is Map<String, dynamic>) {
      return Community.fromJson(data);
    }
    if (data is Map) {
      return Community.fromJson(Map<String, dynamic>.from(data as Map));
    }
    throw ApiException('잘못된 커뮤니티 응답 형식입니다.');
  }

  /// 커뮤니티 생성 POST /communities
  static Future<Community> createCommunity({
    required String name,
    String? description,
  }) async {
    final body = {
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
    };

    final data = await post('/communities', body: body);

    if (data is Map<String, dynamic>) {
      return Community.fromJson(data);
    }
    if (data is Map) {
      return Community.fromJson(Map<String, dynamic>.from(data as Map));
    }
    throw ApiException('커뮤니티 생성 응답이 올바르지 않습니다.');
  }

  /// 커뮤니티 가입 POST /communities/{id}/join
  static Future<void> joinCommunity(int communityId) async {
    await post('/communities/$communityId/join');
  }

  /// 커뮤니티 탈퇴 POST /communities/{id}/leave
  static Future<void> leaveCommunity(int communityId) async {
    await post('/communities/$communityId/leave');
  }

  /// 게시글 목록 GET /communities/{id}/posts
  static Future<List<Post>> getCommunityPosts(int communityId) async {
    final data = await get('/communities/$communityId/posts');

    List<dynamic> items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['items'] is List) {
      items = List<dynamic>.from(data['items'] as List);
    } else {
      return [];
    }

    return items
        .where((e) => e is Map)
        .map((e) => Post.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// 게시글 작성 POST /communities/{id}/posts
  static Future<Post> createPost({
    required int communityId,
    required String title,
    required String content,
  }) async {
    final body = {
      'title': title,
      'content': content,
    };

    final data = await post('/communities/$communityId/posts', body: body);

    if (data is Map<String, dynamic>) {
      return Post.fromJson(data);
    }
    if (data is Map) {
      return Post.fromJson(Map<String, dynamic>.from(data as Map));
    }

    throw ApiException('게시글 생성 응답이 올바르지 않습니다.');
  }

  /// 게시글 수정 PATCH /communities/posts/{post_id}
  static Future<Post> updatePost({
    required int postId,
    required String title,
    required String content,
  }) async {
    final body = {
      'title': title,
      'content': content,
    };

    final data = await patch('/communities/posts/$postId', body: body);

    if (data is Map<String, dynamic>) {
      return Post.fromJson(data);
    }
    if (data is Map) {
      return Post.fromJson(Map<String, dynamic>.from(data as Map));
    }

    throw ApiException('게시글 수정 응답이 올바르지 않습니다.');
  }

  /// 게시글 삭제 DELETE /communities/posts/{post_id}
  static Future<void> deletePost(int postId) async {
    await delete('/communities/posts/$postId');
  }

  /// 게시글 좋아요 토글 POST /communities/posts/{post_id}/like
  ///
  /// 백엔드에서 최종 Post 객체를 돌려주면 파싱, 아니면 에러 없으면 통과만.
  static Future<Post?> toggleLikePost(int postId) async {
    final data = await post('/communities/posts/$postId/like');

    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      return Post.fromJson(data);
    }
    if (data is Map) {
      return Post.fromJson(Map<String, dynamic>.from(data as Map));
    }

    return null;
  }

  /// 댓글 목록 GET /communities/posts/{post_id}/comments
  static Future<List<Comment>> getComments(int postId) async {
    final data = await get('/communities/posts/$postId/comments');

    List<dynamic> items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['items'] is List) {
      items = List<dynamic>.from(data['items'] as List);
    } else {
      return [];
    }

    return items
        .where((e) => e is Map)
        .map((e) => Comment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// 댓글 작성 POST /communities/posts/{post_id}/comments
  static Future<Comment> createComment({
    required int postId,
    required String content,
  }) async {
    final body = {
      'content': content,
    };

    final data =
        await post('/communities/posts/$postId/comments', body: body);

    if (data is Map<String, dynamic>) {
      return Comment.fromJson(data);
    }
    if (data is Map) {
      return Comment.fromJson(Map<String, dynamic>.from(data as Map));
    }

    throw ApiException('댓글 생성 응답이 올바르지 않습니다.');
  }

  /// 댓글 수정 PATCH /communities/comments/{comment_id}
  static Future<Comment> updateComment({
    required int commentId,
    required String content,
  }) async {
    final body = {
      'content': content,
    };

    final data =
        await patch('/communities/comments/$commentId', body: body);

    if (data is Map<String, dynamic>) {
      return Comment.fromJson(data);
    }
    if (data is Map) {
      return Comment.fromJson(Map<String, dynamic>.from(data as Map));
    }

    throw ApiException('댓글 수정 응답이 올바르지 않습니다.');
  }

  /// 댓글 삭제 DELETE /communities/comments/{comment_id}
  static Future<void> deleteComment(int commentId) async {
    await delete('/communities/comments/$commentId');
  }

  /// 게시글 신고 POST /communities/posts/{post_id}/report
  static Future<void> reportPost({
    required int postId,
    required String reason,
    String? detail,
  }) async {
    final body = {
      'reason': reason,
      if (detail != null && detail.isNotEmpty) 'detail': detail,
    };

    await post('/communities/posts/$postId/report', body: body);
  }

  /// 댓글 신고 POST /communities/comments/{comment_id}/report
  static Future<void> reportComment({
    required int commentId,
    required String reason,
    String? detail,
  }) async {
    final body = {
      'reason': reason,
      if (detail != null && detail.isNotEmpty) 'detail': detail,
    };

    await post('/communities/comments/$commentId/report', body: body);
  }
}
