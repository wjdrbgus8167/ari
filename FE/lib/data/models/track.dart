import 'package:ari/domain/entities/track.dart' as domain;
import 'package:ari/data/models/track.dart' as model;
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
  final int albumId;

  @HiveField(6)
  final String trackFileUrl; // 🔹 음원 파일 URL

  @HiveField(7)
  final String lyrics; // 🔹 가사

  @HiveField(8)
  final int trackLikeCount; // 🔹 좋아요 수

  @HiveField(9)
  final String? coverUrl; // 🔹 앨범 커버 이미지 URL (nullable)

  @HiveField(10)
  final int artistId;
  Track({
    required this.id,
    required this.trackTitle,
    required this.artist,
    required this.composer,
    required this.lyricist,
    required this.albumId,
    required this.trackFileUrl,
    required this.lyrics,
    required this.artistId,
    this.coverUrl,
    this.trackLikeCount = 0,
  });

  /// ✅ clone 메서드 추가
  Track clone() {
    return Track(
      id: id,
      trackTitle: trackTitle,
      artist: artist,
      composer: composer,
      lyricist: lyricist,
      albumId: albumId,
      trackFileUrl: trackFileUrl,
      lyrics: lyrics,
      coverUrl: coverUrl,
      trackLikeCount: trackLikeCount,
      artistId: artistId,
    );
  }

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
      artistId: track.artistId,
    );
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['trackId'],
      trackTitle: json['trackTitle'],
      artist: json['artist'],
      composer: json['composer'] ?? '', // API 응답에 없는 필드는 기본값 사용
      lyricist: json['lyricist'] ?? '', // API 응답에 없는 필드는 기본값 사용
      albumId: json['albumId'] ?? 0, // API 응답에 없을 수 있음
      trackFileUrl: json['trackFileUrl'] ?? '', // API 응답에 없을 수 있음
      lyrics: json['lyrics'] ?? '', // API 응답에 없는 필드
      coverUrl: json['coverImageUrl'], // API에서는 coverImageUrl
      trackLikeCount: json['trackLikeCount'] ?? 0, // API 응답에 없는 필드
      artistId: json['artistId'] ?? 0, // API 응답에 없는 필드
    );
  }
}

domain.Track mapDataTrackToDomain(model.Track dataTrack) {
  return domain.Track(
    trackId: dataTrack.id,
    albumTitle: '',
    genreName: '',
    trackTitle: dataTrack.trackTitle,
    artistName: dataTrack.artist,
    composer: [dataTrack.composer],
    lyricist: [dataTrack.lyricist],
    albumId: dataTrack.albumId,
    trackFileUrl: dataTrack.trackFileUrl,
    lyric: dataTrack.lyrics,
    coverUrl: dataTrack.coverUrl,
    trackLikeCount: dataTrack.trackLikeCount,
    commentCount: 0,
    comments: [],
    trackNumber: 0,
    createdAt: DateTime.now().toString(),
  );
}
