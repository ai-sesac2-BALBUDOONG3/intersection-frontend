// lib/screens/community_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/models/post.dart';
import 'package:intersection/services/api_service.dart';

import 'community_write_screen.dart';
import 'comment_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isLoadingCommunities = true;
  bool _isLoadingPosts = true;
  String? _errorMessage;

  List<Community> _communities = [];
  Community? _selectedCommunity;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    await _loadCommunities();
    if (_selectedCommunity != null) {
      await _loadPosts(_selectedCommunity!.id);
    }
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoadingCommunities = true;
      _errorMessage = null;
    });

    try {
      final items = await ApiService.getCommunities();
      setState(() {
        _communities = items;
        if (items.isNotEmpty) {
          _selectedCommunity = items.firstWhere(
            (c) => c.isMember,
            orElse: () => items.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = '커뮤니티 목록을 불러오지 못했어요.\n$e';
      });
    } finally {
      setState(() {
        _isLoadingCommunities = false;
      });
    }
  }

  Future<void> _loadPosts(int communityId) async {
    setState(() {
      _isLoadingPosts = true;
      _errorMessage = null;
    });

    try {
      final items = await ApiService.getCommunityPosts(communityId);
      setState(() {
        _posts = items;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '게시글을 불러오지 못했어요.\n$e';
      });
    } finally {
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> _refreshAll() async {
    await _loadCommunities();
    if (_selectedCommunity != null) {
      await _loadPosts(_selectedCommunity!.id);
    }
  }

  void _onSelectCommunity(Community c) async {
    setState(() {
      _selectedCommunity = c;
    });
    await _loadPosts(c.id);
  }

  void _onWritePost() async {
    final community = _selectedCommunity;
    if (community == null) return;

    final result = await Navigator.push<Post?>(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityWriteScreen(
          community: community,
        ),
      ),
    );

    if (result != null) {
      // 새 글 맨 앞에 추가
      setState(() {
        _posts.insert(0, result);
      });
    }
  }

  void _openPostDetail(Post post) async {
    final result = await Navigator.push<Post?>(
      context,
      MaterialPageRoute(
        builder: (_) => CommentScreen(
          post: post,
          communityName: _selectedCommunity?.name ?? '',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _posts.indexWhere((p) => p.id == result.id);
        if (index >= 0) {
          _posts[index] = result;
        }
      });
    }
  }

  Future<void> _toggleLike(Post post) async {
    try {
      final updated = await ApiService.toggleLikePost(post.id);
      setState(() {
        final idx = _posts.indexWhere((p) => p.id == post.id);
        if (idx >= 0) {
          _posts[idx] = updated ??
              post.copyWith(
                likedByMe: !post.likedByMe,
                likeCount:
                    post.likeCount + (post.likedByMe ? -1 : 1),
              );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 처리 중 오류가 발생했어요.\n$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedCommunity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        actions: [
          IconButton(
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: selected == null
          ? null
          : FloatingActionButton(
              onPressed: _onWritePost,
              child: const Icon(Icons.edit),
            ),
      body: Column(
        children: [
          // 커뮤니티 탭 영역
          SizedBox(
            height: 70,
            child: _buildCommunitySelector(),
          ),

          const Divider(height: 1),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final c = _selectedCommunity;
                if (c != null) {
                  await _loadPosts(c.id);
                }
              },
              child: _buildPostList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySelector() {
    if (_isLoadingCommunities) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_communities.isEmpty) {
      return Center(
        child: Text(
          '아직 생성된 커뮤니티가 없어요.\n첫 글을 올려볼까요?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      itemCount: _communities.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final c = _communities[index];
        final isSelected = c.id == _selectedCommunity?.id;

        return ChoiceChip(
          label: Text(
            c.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => _onSelectCommunity(c),
        );
      },
    );
  }

  Widget _buildPostList() {
    if (_isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
        ],
      );
    }

    if (_posts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Center(
            child: Text(
              '아직 작성된 글이 없어요.\n첫 번째 글의 주인공이 되어보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => _openPostDetail(post),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        post.authorName.isNotEmpty
                            ? post.authorName
                            : '익명',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _toggleLike(post),
                        icon: Icon(
                          post.likedByMe
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: post.likedByMe
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
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
            ),
          ),
        );
      },
    );
  }
}
