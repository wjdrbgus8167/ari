import 'package:ari/domain/entities/track.dart';

class Album {
  final int id;
  final String title;
  final String genre;
  final String artist;
  final int artistId; // 아티스트 ID (정수형으로 변경)
  final String coverUrl; // 앨범 커버 이미지 URL
  final DateTime releaseDate;
  final List<Track> tracks;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.genre,
    this.coverUrl = '', // 기본값 빈 문자열 또는 기본 URL
    required this.releaseDate,
    this.tracks = const [], // 기본값 빈 리스트
  });

  // JSON 데이터를 Album 객체로 변환하는 factory constructor 추가
  factory Album.fromJson(Map<String, dynamic> json) {
    print('[DEBUG] 앨범 JSON: $json'); // ✅ 추가
    print('[DEBUG] json["tracks"]: ${json["tracks"]}'); // ✅ 추가

    return Album(
      id: json['albumId'],
      title: json['albumTitle'],
      artist: json['artist'],
      artistId: json['artistId'] ?? 0, // 아티스트 ID가 없으면 0 사용
      genre: json['genreName'] ?? '', // genre 필드가 없으면 빈 문자열 사용
      coverUrl: json['coverImageUrl'] ?? '',
      // releaseDate가 없는 경우 기본값으로 현재 시간을 사용하거나 다른 기본값 지정
      releaseDate:
          json.containsKey('releaseDate') && json['releaseDate'] != null
              ? DateTime.parse(json['releaseDate'])
              : DateTime.now(),
      tracks:
          json['tracks'] != null
              ? (json['tracks'] as List).map((e) {
                print('[DEBUG] 🎵 트랙 JSON: $e');
                return Track.fromJson(
                  Map<String, dynamic>.from(e),
                  json['albumId'],
                );
              }).toList()
              : [],
    );
  }
}
