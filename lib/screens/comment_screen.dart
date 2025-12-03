// lib/screens/comment_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/models/post.dart';
import 'package:intersection/services/api_service.dart';

import 'community_write_screen.dart';
import 'report_screen.dart';

class CommentScreen extends StatefulWidget {
  final Post post;
  final String communityName;

  const CommentScreen({
    super.key,
    required this.post,
    this.communityName = '', // ✅ 이제 필수 아님 + 기본값
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  late Post _post;

  // bool _isLoading = true;  // ✅ 실제로 안 써서 제거
  bool _isLoadingComments = true;
  String? _errorMessage;

  List<Comment> _comments = [];
  final _commentController = TextEditingController();
  bool _sendingComment = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadPostAndComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostAndComments() async {
    setState(() {
      // _isLoading = true;  // ✅ 제거
      _isLoadingComments = true;
      _errorMessage = null;
    });

    try {
      final comments = await ApiService.getComments(_post.id);

      setState(() {
        _comments = comments;
        _post = _post.copyWith(commentCount: comments.length);
      });
    } catch (e) {
      setState(() {
        _errorMessage = '댓글을 불러오지 못했어요.\n$e';
      });
    } finally {
      setState(() {
        // _isLoading = false;  // ✅ 제거
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _sendingComment = true;
    });

    try {
      final created = await ApiService.createComment(
        postId: _post.id,
        content: text,
      );

      setState(() {
        _comments.add(created);
        _post = _post.copyWith(commentCount: _comments.length);
        _commentController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 작성 중 오류가 발생했어요.\n$e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sendingComment = false;
        });
      }
    }
  }

  Future<void> _deleteComment(Comment c) async {
    try {
      await ApiService.deleteComment(c.id);
      setState(() {
        _comments.removeWhere((x) => x.id == c.id);
        _post = _post.copyWith(commentCount: _comments.length);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 삭제 중 오류가 발생했어요.\n$e')),
      );
    }
  }

  Future<void> _editPost() async {
    final updated = await Navigator.push<Post?>(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityWriteScreen(
          community: Community(
            id: _post.communityId,
            name: widget.communityName,
            description: null,
            memberCount: 0,
            isMember: true,
          ),
          editingPost: _post,
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        _post = updated;
      });
    }
  }

  Future<void> _deletePost() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말 이 게시글을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await ApiService.deletePost(_post.id);
      if (!mounted) return;
      Navigator.pop(context, _post);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 삭제 중 오류가 발생했어요.\n$e')),
      );
    }
  }

  void _openReportForPost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(
          postId: _post.id,
          commentId: null,
        ),
      ),
    );
  }

  void _openReportForComment(Comment c) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(
          postId: null,
          commentId: c.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.communityName.isEmpty ? '게시글' : widget.communityName,
        ),
        actions: [
          IconButton(
            onPressed: _openReportForPost,
            icon: const Icon(Icons.flag_outlined),
          ),
          if (post.isMine) ...[
            IconButton(
              onPressed: _editPost,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: _deletePost,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildPostHeader(post),
          const Divider(height: 1),
          Expanded(
            child: _buildComments(),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostHeader(Post post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.content,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                post.authorName.isNotEmpty ? post.authorName : '익명',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              const Icon(Icons.favorite, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                post.likeCount.toString(),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chat_bubble_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                post.commentCount.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    if (_isLoadingComments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ],
      );
    }

    if (_comments.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            '아직 댓글이 없어요. 첫 댓글을 남겨보세요!',
            style: TextStyle(fontSize: 13),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _comments.length,
      separatorBuilder: (_, __) => const Divider(height: 20),
      itemBuilder: (context, index) {
        final c = _comments[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        c.authorName.isNotEmpty ? c.authorName : '익명',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.flag_outlined, size: 18),
                        onPressed: () => _openReportForComment(c),
                      ),
                      if (c.isMine)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () => _deleteComment(c),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.content,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: const Border(
            top: BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '댓글을 입력해 주세요',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sendingComment ? null : _sendComment,
              icon: _sendingComment
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
