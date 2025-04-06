// lib/domain/mappers/playlist_track_item_mapper.dart
import 'package:ari/domain/entities/playlist_trackitem.dart';
import 'package:ari/domain/entities/track.dart';

extension PlaylistTrackItemMapper on PlaylistTrackItem {
  Track toDomainTrack() {
    return Track(
      trackId: trackId,
      albumId: albumId,
      trackTitle: trackTitle,
      artistName: artist,
      lyric: lyrics,
      composer: [composer],
      lyricist: [lyricist],
      coverUrl: coverImageUrl,
      trackFileUrl: trackFileUrl,
      commentCount: 0,
      comments: [],
      trackNumber: trackNumber,
      trackLikeCount: trackLikeCount,
      createdAt: '', // 서버에 없으면 빈 값 처리
      albumTitle: '', // 서버에 없으면 빈 값 처리
      genreName: '', // 서버에 없으면 빈 값 처리
    );
  }
}
