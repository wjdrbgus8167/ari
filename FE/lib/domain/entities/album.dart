import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/entities/album_comment.dart';

class AlbumSummary {
  final int id;
  final String title;
  final String artist;
  final String coverImageUrl;

  const AlbumSummary({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverImageUrl,
  });
}

class AlbumDetail {
  final String id;
  final String title;
  final String artist;
  final String coverImageUrl;
  final String releaseDate;
  final String genre;
  final String? description;
  final int playCount;
  final int likeCount;
  final double rating;
  final bool isLiked;
  final List<Track> tracks;
  final List<AlbumComment> comments;

  const AlbumDetail({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverImageUrl,
    required this.releaseDate,
    required this.genre,
    required this.comments,
    this.description,
    required this.tracks,
    this.playCount = 0,
    this.likeCount = 0,
    this.rating = 0.0,
    this.isLiked = false,
  });
}