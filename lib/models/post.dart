// lib/models/post.dart

class Community {
  final int id;
  final String name;
  final String? description;
  final int memberCount;
  final bool isMember;

  Community({
    required this.id,
    required this.name,
    this.description,
    required this.memberCount,
    required this.isMember,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return Community(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      memberCount: parseInt(json['member_count'] ?? json['members'] ?? 0),
      isMember: json['is_member'] == true,
    );
  }
}

class Post {
  final int id;
  final int communityId;
  final String title;
  final String content;
  final String authorName;
  final int? authorId;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final bool isMine;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Post({
    required this.id,
    required this.communityId,
    required this.title,
    required this.content,
    required this.authorName,
    this.authorId,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
    required this.isMine,
    required this.createdAt,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    String resolveAuthorName(Map<String, dynamic> data) {
      if (data['author_name'] != null) {
        return data['author_name'].toString();
      }
      if (data['author'] is Map) {
        final a = Map<String, dynamic>.from(data['author'] as Map);
        if (a['nickname'] != null) return a['nickname'].toString();
        if (a['real_name'] != null) return a['real_name'].toString();
      }
      return '';
    }

    return Post(
      id: parseInt(json['id']),
      communityId: parseInt(json['community_id']),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      authorName: resolveAuthorName(json),
      authorId:
          json['author_id'] != null ? parseInt(json['author_id']) : null,
      likeCount: parseInt(json['like_count'] ?? json['likes'] ?? 0),
      commentCount: parseInt(json['comment_count'] ?? json['comments'] ?? 0),
      likedByMe: json['liked_by_me'] == true,
      isMine: json['is_mine'] == true,
      createdAt:
          parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Post copyWith({
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
  }) {
    return Post(
      id: id,
      communityId: communityId,
      title: title,
      content: content,
      authorName: authorName,
      authorId: authorId,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
      isMine: isMine,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class Comment {
  final int id;
  final int postId;
  final String content;
  final String authorName;
  final int? authorId;
  final bool isMine;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorName,
    this.authorId,
    required this.isMine,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    DateTime parseDate(dynamic v) {
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    String resolveAuthorName(Map<String, dynamic> data) {
      if (data['author_name'] != null) {
        return data['author_name'].toString();
      }
      if (data['author'] is Map) {
        final a = Map<String, dynamic>.from(data['author'] as Map);
        if (a['nickname'] != null) return a['nickname'].toString();
        if (a['real_name'] != null) return a['real_name'].toString();
      }
      return '';
    }

    return Comment(
      id: parseInt(json['id']),
      postId: parseInt(json['post_id']),
      content: json['content']?.toString() ?? '',
      authorName: resolveAuthorName(json),
      authorId:
          json['author_id'] != null ? parseInt(json['author_id']) : null,
      isMine: json['is_mine'] == true,
      createdAt: parseDate(json['created_at']),
    );
  }
}
