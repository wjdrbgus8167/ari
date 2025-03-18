import './album.dart';

class Track {
  final String id;
  final String trackTitle; // 🔹 트랙 제목
  final String artist;
  final String composer; // 🔹 작곡가
  final String lyricist; // 🔹 작사가
  final String albumId;
  final String trackFileUrl; // 🔹 음원 파일 URL
  final String lyrics; // 🔹 가사
  final int trackLikeCount; // 🔹 좋아요 수
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
    this.coverUrl, // ✅ 앨범에서 자동으로 가져오기 위해 nullable 설정
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
      coverUrl: album.coverUrl, // ✅ album에서 coverUrl 가져오기
      trackLikeCount: track.trackLikeCount,
    );
  }
}
