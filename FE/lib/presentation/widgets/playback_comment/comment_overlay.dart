import 'dart:ui';
import 'package:ari/data/models/comment.dart';
import 'package:ari/data/datasources/comment_remote_datasource.dart';
import 'package:ari/presentation/widgets/playback_comment/comment_input_field.dart';
import 'package:ari/providers/playback/playback_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/global_providers.dart' as gb;
import 'package:ari/core/services/audio_service.dart';

class CommentOverlay extends ConsumerStatefulWidget {
  final String timestamp;
  final VoidCallback onClose;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;
  final int trackId;
  final int albumId;

  const CommentOverlay({
    super.key,
    required this.timestamp,
    required this.onClose,
    required this.trackTitle,
    required this.artist,
    required this.coverImageUrl,
    required this.trackId,
    required this.albumId,
  });

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
    commentDatasource = CommentRemoteDatasource(dio: ref.watch(gb.dioProvider));
    _commentsFuture = commentDatasource.fetchComments(widget.trackId);
  }

  void _refreshComments() {
    setState(() {
      _commentsFuture = commentDatasource.fetchComments(widget.trackId);
    });
  }

  /// "mm:ss" 문자열을 Duration으로 변환하는 헬퍼 함수
  Duration _parseTimestamp(String timestamp) {
    final parts = timestamp.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: minutes, seconds: seconds);
    }
    return Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    final positionAsyncValue = ref.watch(playbackPositionProvider);
    final Duration currentPosition = positionAsyncValue.when(
      data: (duration) => duration,
      loading: () => Duration.zero,
      error: (_, __) => Duration.zero,
    );

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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _CommentOverlayHeader(onClose: widget.onClose),
                  const Divider(height: 1, color: Colors.grey),
                  _TrackInfoWidget(
                    trackTitle: widget.trackTitle,
                    artist: widget.artist,
                    coverImageUrl: widget.coverImageUrl,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: FutureBuilder<List<Comment>>(
                      future: _commentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Text(
                            "댓글 ${snapshot.data!.length}개",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FutureBuilder<List<Comment>>(
                      future: _commentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              '댓글을 불러오는 중 오류가 발생했습니다.',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              '아직 댓글이 없습니다.',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          );
                        } else {
                          final comments = snapshot.data!;
                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: 80,
                            ), // 키보드 + 입력창 높이 고려
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage:
                                          comment.profileImageUrl != null
                                              ? NetworkImage(
                                                comment.profileImageUrl!,
                                              )
                                              : const NetworkImage(
                                                "https://placehold.co/40x40",
                                              ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                comment.nickname,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${comment.createdAt.year}.${comment.createdAt.month}.${comment.createdAt.day}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  comment.content,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  final timestampStr =
                                                      comment.timestamp ??
                                                      '${comment.createdAt.hour}:${comment.createdAt.minute.toString().padLeft(2, '0')}';
                                                  final duration =
                                                      _parseTimestamp(
                                                        timestampStr,
                                                      );
                                                  ref
                                                      .read(
                                                        audioServiceProvider,
                                                      )
                                                      .seekTo(duration);
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    comment.timestamp ??
                                                        '${comment.createdAt.hour}:${comment.createdAt.minute.toString().padLeft(2, '0')}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
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

                  /// 키보드 올라와도 댓글창 보이도록 SafeArea 밖
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: CommentInputField(
                      timestamp: widget.timestamp,
                      trackId: widget.trackId,
                      albumId: widget.albumId,
                      commentDatasource: commentDatasource,
                      onCommentSent: _refreshComments,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CommentOverlayHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _CommentOverlayHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
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
    super.key,
    required this.trackTitle,
    required this.artist,
    required this.coverImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              coverImageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trackTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  artist,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
