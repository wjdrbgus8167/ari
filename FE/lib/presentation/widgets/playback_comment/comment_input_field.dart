import 'package:flutter/material.dart';
import 'package:ari/data/datasources/comment_remote_datasource.dart';

class CommentInputField extends StatefulWidget {
  final String timestamp;
  final int trackId;
  final int albumId;
  final CommentRemoteDatasource commentDatasource;
  final VoidCallback onCommentSent;

  const CommentInputField({
    super.key,
    required this.timestamp,
    required this.trackId,
    required this.albumId,
    required this.commentDatasource,
    required this.onCommentSent,
  });

  @override
  _CommentInputFieldState createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  Future<void> _sendComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await widget.commentDatasource.postComment(
        albumId: widget.albumId,
        trackId: widget.trackId,
        content: content,
        contentTimestamp: widget.timestamp,
      );
      _controller.clear();
      widget.onCommentSent();
      _focusNode.unfocus(); // 포커스 해제
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
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onSubmitted: (_) => _sendComment(),
                  decoration: InputDecoration(
                    hintText: "댓글을 남겨보세요...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    // suffixIcon 제거됨!
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    widget.timestamp,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _isSending
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendComment,
              ),
        ],
      ),
    );
  }
}
