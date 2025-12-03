// lib/screens/recommended_friends_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/services/api_service.dart';

/// /match/recommendations 기반 추천 친구 리스트
/// (탭 body 용 – Scaffold 없음)
class RecommendedFriendsScreen extends StatefulWidget {
  const RecommendedFriendsScreen({super.key});

  @override
  State<RecommendedFriendsScreen> createState() =>
      _RecommendedFriendsScreenState();
}

class _RecommendedFriendsScreenState extends State<RecommendedFriendsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<MatchRecommendation> _recommended = [];

  @override
  void initState() {
    super.initState();
    _loadRecommended();
  }

  Future<void> _loadRecommended() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ static GET 사용
      final dynamic res = await ApiService.get(
        '/match/recommendations',
        queryParameters: {
          'limit': 20,
          'with_reasons': true,
        },
      );

      List<dynamic> rawList;
      if (res is List) {
        rawList = res;
      } else if (res is Map && res['items'] is List) {
        rawList = res['items'] as List<dynamic>;
      } else if (res is Map && res['results'] is List) {
        rawList = res['results'] as List<dynamic>;
      } else {
        throw ApiException('알 수 없는 추천 응답 형식입니다.', statusCode: null);
      }

      final parsed = rawList
          .whereType<Map<String, dynamic>>()
          .map(MatchRecommendation.fromJson)
          .toList();

      setState(() {
        _recommended = parsed;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '추천 친구 불러오기에 실패했어요.\n$e';
      });
    }
  }

  Future<void> _requestFriend(MatchRecommendation rec) async {
    if (rec.isRequested) return;

    try {
      await ApiService.post('/friends/requests/${rec.userId}');

      if (!mounted) return;
      setState(() {
        rec.isRequested = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${rec.displayName}님께 친구 요청을 보냈어요.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 요청 실패: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 요청 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadRecommended,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '당신과 학교/시기/지역/기억이 겹치는 친구들을 추천해요',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_recommended.isEmpty && _errorMessage == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  '현재 추천할 친구가 없어요.\n조금만 더 사용하면 추천이 생길 거예요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),

          if (_recommended.isNotEmpty)
            ..._recommended.map(
              (rec) => _RecommendationCard(
                recommendation: rec,
                onTap: () {
                  // TODO: 프로필 상세 API 완성되면 친구 프로필 화면으로 이동
                },
                onRequestFriend: () => _requestFriend(rec),
              ),
            ),
        ],
      ),
    );
  }
}

class MatchRecommendation {
  final int userId;
  final String displayName;
  final String? schoolSummary;
  final String? regionSummary;
  final double? score;
  final String? reason;
  final List<String> commonTags;
  bool isRequested;

  MatchRecommendation({
    required this.userId,
    required this.displayName,
    this.schoolSummary,
    this.regionSummary,
    this.score,
    this.reason,
    this.commonTags = const [],
    this.isRequested = false,
  });

  factory MatchRecommendation.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] is Map<String, dynamic>)
        ? (json['user'] as Map<String, dynamic>)
        : json;

    final dynamic idRaw =
        userJson['id'] ?? userJson['user_id'] ?? userJson['uid'];
    int userId;
    if (idRaw is int) {
      userId = idRaw;
    } else if (idRaw is String) {
      userId = int.tryParse(idRaw) ?? 0;
    } else {
      userId = 0;
    }

    final displayName = (userJson['nickname'] ??
            userJson['real_name'] ??
            userJson['name'] ??
            '알 수 없음')
        .toString();

    final schoolSummary = (json['common_school'] ??
            json['school_summary'] ??
            userJson['school_summary'])
        ?.toString();

    final regionSummary = (json['common_region'] ??
            json['region_summary'] ??
            userJson['region'])
        ?.toString();

    double? score;
    final dynamic scoreRaw = json['score'] ?? json['match_score'];
    if (scoreRaw is num) {
      score = scoreRaw.toDouble();
    } else if (scoreRaw is String) {
      score = double.tryParse(scoreRaw);
    }

    final reason = (json['reason'] ??
            json['gpt_reason'] ??
            json['match_reason'])
        ?.toString();

    final tags = <String>[];
    if (json['tags'] is List) {
      tags.addAll(
        (json['tags'] as List)
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    }
    if (schoolSummary != null && schoolSummary.isNotEmpty) {
      tags.add(schoolSummary);
    }
    if (regionSummary != null && regionSummary.isNotEmpty) {
      tags.add(regionSummary);
    }

    final uniqueTags = tags.toSet().toList();

    return MatchRecommendation(
      userId: userId,
      displayName: displayName,
      schoolSummary: schoolSummary,
      regionSummary: regionSummary,
      score: score,
      reason: reason,
      commonTags: uniqueTags,
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final MatchRecommendation recommendation;
  final VoidCallback onTap;
  final VoidCallback onRequestFriend;

  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
    required this.onRequestFriend,
  });

  @override
  Widget build(BuildContext context) {
    final rec = recommendation;
    final initials =
        rec.displayName.isNotEmpty ? rec.displayName[0] : '?';

    final scoreText = rec.score != null
        ? (rec.score! > 1
            ? rec.score!.toStringAsFixed(0)
            : '${(rec.score! * 100).toStringAsFixed(0)}')
        : null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (rec.schoolSummary != null)
                              rec.schoolSummary!,
                            if (rec.regionSummary != null)
                              rec.regionSummary!,
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (scoreText != null && scoreText.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 14,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$scoreText%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed:
                            rec.isRequested ? null : onRequestFriend,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(80, 32),
                        ),
                        child: Text(
                          rec.isRequested ? '요청됨' : '친구 요청',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (rec.commonTags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: -4,
                  children: rec.commonTags
                      .map(
                        (t) => Chip(
                          label: Text(
                            t,
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],
              if (rec.reason != null && rec.reason!.isNotEmpty)
                Text(
                  rec.reason!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
