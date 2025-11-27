// lib/models/match_recommendation.dart

class MatchScoreBreakdownModel {
  final double finalScore;
  final double schoolScore;
  final double regionScore;
  final double yearScore;
  final double keywordScore;
  final double embeddingScore;

  MatchScoreBreakdownModel({
    required this.finalScore,
    required this.schoolScore,
    required this.regionScore,
    required this.yearScore,
    required this.keywordScore,
    required this.embeddingScore,
  });

  factory MatchScoreBreakdownModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v is int) return v.toDouble();
      if (v is double) return v;
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return MatchScoreBreakdownModel(
      finalScore: _toDouble(json['final_score']),
      schoolScore: _toDouble(json['school_score']),
      regionScore: _toDouble(json['region_score']),
      yearScore: _toDouble(json['year_score']),
      keywordScore: _toDouble(json['keyword_score']),
      embeddingScore: _toDouble(json['embedding_score']),
    );
  }
}

class MatchRecommendationModel {
  final int candidateUserId;
  final String nickname;
  final MatchScoreBreakdownModel scores;
  final String? reason;

  MatchRecommendationModel({
    required this.candidateUserId,
    required this.nickname,
    required this.scores,
    this.reason,
  });

  factory MatchRecommendationModel.fromJson(Map<String, dynamic> json) {
    return MatchRecommendationModel(
      candidateUserId: json['candidate_user_id'] as int,
      nickname: json['nickname'] as String,
      scores: MatchScoreBreakdownModel.fromJson(
        json['scores'] as Map<String, dynamic>,
      ),
      reason: json['reason'] as String?,
    );
  }
}
