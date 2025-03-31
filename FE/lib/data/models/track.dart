import 'package:ari/data/models/album.dart';
import 'package:hive/hive.dart';

part 'track.g.dart';

@HiveType(typeId: 0)
class Track extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String trackTitle; // 🔹 트랙 제목

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String composer; // 🔹 작곡가

  @HiveField(4)
  final String lyricist; // 🔹 작사가

  @HiveField(5)
  final String albumId;

  @HiveField(6)
  final String trackFileUrl; // 🔹 음원 파일 URL

  @HiveField(7)
  final String lyrics; // 🔹 가사

  @HiveField(8)
  final int trackLikeCount; // 🔹 좋아요 수

  @HiveField(9)
  final String? coverUrl; // 🔹 앨범 커버 이미지 URL (nullable)

  Track({
    required this.id,
    required this.trackTitle,
    required this.artist,
    required this.composer,
    required this.lyricist,
    required this.albumId,
    required this.trackFileUrl,
    required this.lyrics,
    this.coverUrl,
    this.trackLikeCount = 0,
  });

  /// ✅ 앨범 데이터를 받아서 coverUrl을 설정하는 팩토리 생성자 추가
  factory Track.fromAlbum({required Track track, required Album album}) {
    return Track(
      id: track.id,
      trackTitle: track.trackTitle,
      artist: track.artist,
      composer: track.composer,
      lyricist: track.lyricist,
      albumId: track.albumId,
      trackFileUrl: track.trackFileUrl,
      lyrics: track.lyrics,
      coverUrl: album.coverUrl,
      trackLikeCount: track.trackLikeCount,
    );
  }
}
