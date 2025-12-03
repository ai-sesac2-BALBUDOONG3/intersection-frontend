// lib/screens/community_write_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/models/post.dart';

/// 커뮤니티 글쓰기 / 수정 화면
///
/// - 호출 패턴 예시:
///   - CommunityWriteScreen(communityName: '동네방네')
///   - CommunityWriteScreen(community: someCommunityObject)
///   - CommunityWriteScreen(editingPost: post)
///   - CommunityWriteScreen()  // 모두 기본값 사용
class CommunityWriteScreen extends StatefulWidget {
  /// 상단에 보여줄 커뮤니티 이름 (텍스트)
  final String? communityName;

  /// 실제 커뮤니티 객체나 기타 식별용 데이터 (타입 제한 X)
  final Object? community;

  /// 수정 모드일 때 넘기는 게시글
  final Post? editingPost;

  const CommunityWriteScreen({
    super.key,
    this.communityName,
    this.community,
    this.editingPost,
  });

  @override
  State<CommunityWriteScreen> createState() => _CommunityWriteScreenState();
}

class _CommunityWriteScreenState extends State<CommunityWriteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get _isEditing => widget.editingPost != null;

  /// 앱바 아래에 노출할 커뮤니티 이름 텍스트
  String get _communityTitle {
    // 1순위: 명시적으로 받은 communityName
    if (widget.communityName != null && widget.communityName!.isNotEmpty) {
      return widget.communityName!;
    }

    // 2순위: community 가 String 이면 그걸 그대로 사용
    if (widget.community is String) {
      return widget.community as String;
    }

    // 3순위: community 가 뭔가 있으면 toString() (디버깅용)
    if (widget.community != null) {
      return widget.community.toString();
    }

    // 기본값
    return '전체 커뮤니티';
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: _isEditing ? (widget.editingPost?.title ?? '') : '',
    );
    _contentController = TextEditingController(
      text: _isEditing ? (widget.editingPost?.content ?? '') : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해 주세요.')),
      );
      return;
    }

    // TODO: 여기서 실제 API 연동 (생성 / 수정)을 붙이면 됨.
    // if (_isEditing) {
    //   await ApiService.updatePost(...);
    // } else {
    //   await ApiService.createPost(...);
    // }

    Navigator.pop(context, true); // 작성/수정 성공했다고 가정
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = _isEditing ? '게시글 수정' : '새 글 작성';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 커뮤니티 이름 표시
            Text(
              _communityTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // 제목
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // 내용
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: '내용',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onSubmit,
                child: Text(_isEditing ? '수정 완료' : '작성 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
