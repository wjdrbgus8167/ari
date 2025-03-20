import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/entities/album_comment.dart';
class Album {
  final int id;
  final String title;
  final String artist;
  final String description;
  final int likeCount;
  final String genre;
  final int commentCount;
  final double rating;
  final String releaseDate;
  final String coverImageUrl;
  final List<AlbumComment> comments;
  final List<Track> tracks;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.likeCount,
    required this.genre,
    required this.commentCount,
    required this.rating,
    required this.releaseDate,
    required this.coverImageUrl,
    required this.comments,
    required this.tracks,
  });
}