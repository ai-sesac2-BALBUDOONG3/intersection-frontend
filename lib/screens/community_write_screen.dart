import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/models/post.dart';

class CommunityWriteScreen extends StatefulWidget {
  const CommunityWriteScreen({super.key});

  @override
  State<CommunityWriteScreen> createState() => _CommunityWriteScreenState();
}

class _CommunityWriteScreenState extends State<CommunityWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool _isPosting = false;

  void _submitPost() {
    final content = _contentController.text.trim();
    final me = AppState.currentUser;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("내용을 입력해줘.")),
      );
      return;
    }

    if (me == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인이 필요해요.")),
      );
      return;
    }

    setState(() => _isPosting = true);

    // 🔥 로컬 저장소에 게시물 추가
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch,
      content: content,
      authorId: me.id,
      createdAt: DateTime.now(),
    );

    AppState.communityPosts.insert(0, newPost);

    setState(() => _isPosting = false);

    Navigator.pop(context, true); // 글 작성 완료 → 커뮤니티 화면으로 복귀
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("새 글 작성"),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _submitPost,
            child: _isPosting
                ? const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Text(
                    "게시",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _contentController,
          minLines: 5,
          maxLines: null,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "무슨 생각을 하고 있나요?",
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
