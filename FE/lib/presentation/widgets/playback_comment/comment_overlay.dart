import 'package:flutter/material.dart';
import 'comment_overlay_header.dart';
import 'track_info_widget.dart';
import 'comment_item.dart';

class CommentOverlay extends StatefulWidget {
  final String timestamp;
  final VoidCallback onClose;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;

  const CommentOverlay({
    Key? key,
    required this.timestamp,
    required this.onClose,
    required this.trackTitle,
    required this.artist,
    required this.coverImageUrl,
  }) : super(key: key);

  @override
  _CommentOverlayState createState() => _CommentOverlayState();
}

class _CommentOverlayState extends State<CommentOverlay> {
  double _dragOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > 100) {
          widget.onClose();
        }
        setState(() {
          _dragOffset = 0.0;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommentOverlayHeader(onClose: widget.onClose),
              const Divider(),
              TrackInfoWidget(
                trackTitle: widget.trackTitle,
                artist: widget.artist,
                coverImageUrl: widget.coverImageUrl,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "댓글 31개",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => const CommentItem(),
                ),
              ),
              _CommentInputField(timestamp: widget.timestamp),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentInputField extends StatelessWidget {
  final String timestamp;

  const _CommentInputField({Key? key, required this.timestamp})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "댓글을 남겨보세요...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          suffix: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              timestamp,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }
}
