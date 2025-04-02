import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/models/comment.dart';
import 'package:ari/data/datasources/comment_remote_datasource.dart';
import 'package:ari/providers/global_providers.dart';
import 'comment_input_field.dart';

class CommentOverlay extends ConsumerStatefulWidget {
  final String timestamp;
  final VoidCallback onClose;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;
  final int trackId;
  final int albumId;

  const CommentOverlay({
    Key? key,
    required this.timestamp,
    required this.onClose,
    required this.trackTitle,
    required this.artist,
    required this.coverImageUrl,
    required this.trackId,
    required this.albumId,
  }) : super(key: key);

  @override
  _CommentOverlayState createState() => _CommentOverlayState();
}

class _CommentOverlayState extends ConsumerState<CommentOverlay> {
  double _dragOffset = 0.0;
  late final CommentRemoteDatasource commentDatasource;
  late Future<List<Comment>> _commentsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // global_providers.dart에 정의된 dioProvider를 활용
    commentDatasource = CommentRemoteDatasource(dio: ref.watch(dioProvider));
    _commentsFuture = commentDatasource.fetchComments(widget.trackId);
  }

  void _refreshComments() {
    setState(() {
      _commentsFuture = commentDatasource.fetchComments(widget.trackId);
    });
  }

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
              const _CommentOverlayHeader(),
              const Divider(),
              _TrackInfoWidget(
                trackTitle: widget.trackTitle,
                artist: widget.artist,
                coverImageUrl: widget.coverImageUrl,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder<List<Comment>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '댓글을 불러오지 못했습니다: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '댓글이 없습니다.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      final comments = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "댓글 ${comments.length}개",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<Comment>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '오류: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          '댓글이 없습니다.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      final comments = snapshot.data!;
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      comment.profileImageUrl != null
                                          ? NetworkImage(
                                            comment.profileImageUrl!,
                                          )
                                          : const NetworkImage(
                                            "https://placehold.co/40x40",
                                          ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            comment.nickname,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                comment.timestamp ??
                                                    '${comment.createdAt.hour}:${comment.createdAt.minute.toString().padLeft(2, '0')}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                '${comment.createdAt.year}-${comment.createdAt.month}-${comment.createdAt.day}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment.content,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              // 댓글 입력 필드 (댓글 전송 후 새로고침)
              CommentInputField(
                timestamp: widget.timestamp,
                trackId: widget.trackId,
                albumId: widget.albumId,
                commentDatasource: commentDatasource,
                onCommentSent: _refreshComments,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentOverlayHeader extends StatelessWidget {
  final VoidCallback? onClose;
  const _CommentOverlayHeader({Key? key, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "댓글",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

class _TrackInfoWidget extends StatelessWidget {
  final String trackTitle;
  final String artist;
  final String coverImageUrl;
  const _TrackInfoWidget({
    Key? key,
    required this.trackTitle,
    required this.artist,
    required this.coverImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        coverImageUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
      title: Text(trackTitle, style: const TextStyle(color: Colors.white)),
      subtitle: Text(artist, style: const TextStyle(color: Colors.white70)),
    );
  }
}
