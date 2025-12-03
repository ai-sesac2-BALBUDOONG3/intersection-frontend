// lib/screens/friend_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/services/api_service.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<FriendRequest> _incoming = [];
  List<FriendRequest> _outgoing = [];

  int _tabIndex = 0; // 0: 받은 요청, 1: 보낸 요청

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ static GET 사용
      final dynamic incomingRes =
          await ApiService.get('/friends/requests/incoming');
      final incomingList = _parseList(incomingRes);

      final dynamic outgoingRes =
          await ApiService.get('/friends/requests/outgoing');
      final outgoingList = _parseList(outgoingRes);

      setState(() {
        _incoming = incomingList;
        _outgoing = outgoingList;
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
        _errorMessage = '친구 요청 목록을 불러오지 못했습니다.\n$e';
      });
    }
  }

  List<FriendRequest> _parseList(dynamic res) {
    List<dynamic> rawList;

    if (res is List) {
      rawList = res;
    } else if (res is Map && res['items'] is List) {
      rawList = res['items'] as List<dynamic>;
    } else if (res is Map && res['results'] is List) {
      rawList = res['results'] as List<dynamic>;
    } else {
      rawList = const [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(FriendRequest.fromJson)
        .toList();
  }

  Future<void> _accept(FriendRequest req) async {
    try {
      await ApiService.post('/friends/requests/${req.id}/accept');
      if (!mounted) return;

      setState(() {
        _incoming.removeWhere((r) => r.id == req.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${req.otherUserName}님을 친구로 추가했습니다.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수락 실패: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수락 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _reject(FriendRequest req) async {
    try {
      await ApiService.post('/friends/requests/${req.id}/reject');
      if (!mounted) return;

      setState(() {
        if (_tabIndex == 0) {
          _incoming.removeWhere((r) => r.id == req.id);
        } else {
          _outgoing.removeWhere((r) => r.id == req.id);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${req.otherUserName}님과의 친구 요청을 정리했습니다.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('처리 실패: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('처리 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabs = ['받은 요청', '보낸 요청'];
    final currentList = _tabIndex == 0 ? _incoming : _outgoing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 요청'),
      ),
      body: Column(
        children: [
          // 상단 탭
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final selected = _tabIndex == index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == 0 ? 4 : 0,
                      left: index == 1 ? 4 : 0,
                    ),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _tabIndex = index;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: selected
                            ? theme.colorScheme.primary.withOpacity(0.08)
                            : null,
                        side: BorderSide(
                          color: selected
                              ? theme.colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected
                              ? theme.colorScheme.primary
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadAll,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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

                        if (currentList.isEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                _tabIndex == 0
                                    ? '받은 친구 요청이 없습니다.'
                                    : '보낸 친구 요청이 없습니다.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          )
                        else
                          ...currentList.map((req) {
                            return _RequestCard(
                              request: req,
                              isIncoming: _tabIndex == 0,
                              onAccept: () => _accept(req),
                              onReject: () => _reject(req),
                            );
                          }),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class FriendRequest {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String otherUserName;
  final String? otherUserSchool;
  final String? otherUserRegion;
  final DateTime? createdAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.otherUserName,
    this.otherUserSchool,
    this.otherUserRegion,
    this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    final dynamic idRaw = json['id'] ?? json['request_id'];
    final id = _parseInt(idRaw);

    Map<String, dynamic>? fromUser;
    Map<String, dynamic>? toUser;
    if (json['from_user'] is Map<String, dynamic>) {
      fromUser = json['from_user'] as Map<String, dynamic>;
    }
    if (json['to_user'] is Map<String, dynamic>) {
      toUser = json['to_user'] as Map<String, dynamic>;
    }

    final fromId = _parseInt(
      json['from_user_id'] ?? fromUser?['id'] ?? fromUser?['user_id'],
    );
    final toId = _parseInt(
      json['to_user_id'] ?? toUser?['id'] ?? toUser?['user_id'],
    );

    // 일단 selfId 모르는 상태 → 받은 목록에서는 상대=from, 보낸 목록에서는 상대=to 로 가정
    final other = fromUser ?? toUser;

    final name = (other?['nickname'] ??
            other?['real_name'] ??
            other?['name'] ??
            '알 수 없음')
        .toString();

    final school = (other?['school_summary'] ?? other?['school'])
        ?.toString();
    final region =
        (other?['region'] ?? other?['base_region'])?.toString();

    DateTime? createdAt;
    final createdRaw = json['created_at'] ?? json['requested_at'];
    if (createdRaw is String) {
      try {
        createdAt = DateTime.parse(createdRaw);
      } catch (_) {}
    }

    return FriendRequest(
      id: id,
      fromUserId: fromId,
      toUserId: toId,
      otherUserName: name,
      otherUserSchool: school,
      otherUserRegion: region,
      createdAt: createdAt,
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

class _RequestCard extends StatelessWidget {
  final FriendRequest request;
  final bool isIncoming;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.isIncoming,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final title = request.otherUserName;
    final subtitleParts = <String>[];
    if (request.otherUserSchool != null &&
        request.otherUserSchool!.isNotEmpty) {
      subtitleParts.add(request.otherUserSchool!);
    }
    if (request.otherUserRegion != null &&
        request.otherUserRegion!.isNotEmpty) {
      subtitleParts.add(request.otherUserRegion!);
    }

    final subtitle = subtitleParts.join(' · ');

    String timeLabel = '';
    if (request.createdAt != null) {
      final dt = request.createdAt!;
      timeLabel =
          '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (timeLabel.isNotEmpty)
              Text(
                timeLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        trailing: isIncoming
            ? _IncomingButtons(
                onAccept: onAccept,
                onReject: onReject,
              )
            : _OutgoingButtons(
                onCancel: onReject,
              ),
      ),
    );
  }
}

class _IncomingButtons extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _IncomingButtons({
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: [
        TextButton(
          onPressed: onReject,
          child: const Text(
            '거절',
            style: TextStyle(fontSize: 12),
          ),
        ),
        FilledButton(
          onPressed: onAccept,
          style: FilledButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
          child: const Text(
            '수락',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _OutgoingButtons extends StatelessWidget {
  final VoidCallback onCancel;

  const _OutgoingButtons({
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onCancel,
      child: const Text(
        '요청 취소',
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
