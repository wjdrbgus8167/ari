// lib/presentation/widgets/playback_comment/comment_input_field.dart
import 'package:flutter/material.dart';
import 'package:ari/data/datasources/comment_remote_datasource.dart';

class CommentInputField extends StatefulWidget {
  final String timestamp;
  final int trackId;
  final int albumId;
  final CommentRemoteDatasource commentDatasource;
  final VoidCallback onCommentSent;

  const CommentInputField({
    Key? key,
    required this.timestamp,
    required this.trackId,
    required this.albumId,
    required this.commentDatasource,
    required this.onCommentSent,
  }) : super(key: key);

  @override
  _CommentInputFieldState createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    setState(() {
      _isSending = true;
    });
    try {
      // albumId는 widget.albumId 사용; 실제 값에 맞게 수정
      await widget.commentDatasource.postComment(
        albumId: widget.albumId,
        trackId: widget.trackId,
        content: content,
        contentTimestamp: widget.timestamp,
      );
      _controller.clear();
      widget.onCommentSent();
    } catch (e) {
      print('댓글 전송 오류: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "댓글을 남겨보세요...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    widget.timestamp,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isSending
              ? const CircularProgressIndicator()
              : IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendComment,
              ),
        ],
      ),
    );
  }
}
