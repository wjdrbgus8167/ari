import 'package:ari/domain/entities/track_comment.dart';

class Track {
  final String id;
  final String albumId;
  final String trackTitle;
  final String artistName;
  final String lyric;
  final int playTime;
  final int trackNumber;
  final int commentCount;
  final List<String> lyricist;
  final List<String> composer;
  final List<TrackComment> comments;
  final String createdAt;
  const Track({
    required this.id,
    required this.albumId,
    required this.trackTitle,
    required this.artistName,
    required this.lyric,
    required this.playTime,
    required this.trackNumber,
    required this.comments,
    this.commentCount = 0,
    required this.lyricist,
    required this.composer,
    required this.createdAt,
  });
}