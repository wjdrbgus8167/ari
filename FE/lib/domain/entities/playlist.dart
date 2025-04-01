// lib/domain/entities/playlist.dart
import 'package:ari/domain/entities/playlist_trackitem.dart';
import 'package:ari/data/models/playlist.dart' as data;

class Playlist {
  final int id;
  final String title;
  final bool isPublic;
  final int shareCount;
  final List<PlaylistTrackItem> tracks;

  const Playlist({
    required this.id,
    required this.title,
    required this.isPublic,
    required this.shareCount,
    required this.tracks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as int,
      title: json['title'] as String,
      isPublic: json['isPublic'] as bool,
      shareCount: json['shareCount'] as int,
      tracks:
          (json['tracks'] as List<dynamic>?)
              ?.map(
                (e) => PlaylistTrackItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  // 도메인 모델을 데이터 모델로 변환하는 메서드
  // 데이터 모델에는 tracks 필드가 없으므로 tracks는 변환하지 않습니다.
  data.Playlist toDataModel() {
    return data.Playlist(
      playlistId: id,
      shareCount: shareCount,
      publicYn: isPublic,
      playlistTitle: title,
    );
  }
}
