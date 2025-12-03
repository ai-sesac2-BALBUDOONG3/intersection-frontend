// lib/screens/report_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/models/post.dart';

/// 게시글/댓글 신고 화면
///
/// - post      : 신고 대상 게시글 객체 (있으면 상단에 미리보기)
/// - postId    : 게시글 ID (post가 없어도 ID만으로 신고할 때 사용 가능)
/// - commentId : 댓글 ID (댓글 신고일 때)
class ReportScreen extends StatefulWidget {
  final Post? post;
  final int? postId;
  final int? commentId;

  const ReportScreen({
    super.key,
    this.post,
    this.postId,
    this.commentId,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<String> _reasons = [
    '광고 / 홍보성 글',
    '욕설 / 비하 / 혐오 표현',
    '음란물 / 불건전한 내용',
    '도배 / 스팸',
    '기타',
  ];

  String? _selectedReason;
  final TextEditingController _detailController = TextEditingController();

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 사유를 선택해주세요.')),
      );
      return;
    }

    // TODO: 백엔드 신고 API 연동 (/reports 등)
    //  - widget.postId / widget.commentId / widget.post 를 활용해서 payload 생성
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('신고가 접수되었습니다. 감사합니다.')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final targetLabel = widget.commentId != null
        ? '댓글 신고'
        : '게시글 신고';

    return Scaffold(
      appBar: AppBar(
        title: Text(targetLabel),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post != null) ...[
              const Text(
                '신고 대상 게시글',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              Text(
                '신고 대상: '
                'postId=${widget.postId ?? '-'}, '
                'commentId=${widget.commentId ?? '-'}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],

            const Text(
              '신고 사유 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ..._reasons.map((reason) {
              return RadioListTile<String>(
                value: reason,
                groupValue: _selectedReason,
                onChanged: (v) {
                  setState(() {
                    _selectedReason = v;
                  });
                },
                title: Text(reason, style: const TextStyle(fontSize: 14)),
              );
            }),

            const SizedBox(height: 24),
            const Text(
              '상세 내용 (선택)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _detailController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '신고 내용을 구체적으로 적어주세요 (선택사항)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('신고 제출'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
