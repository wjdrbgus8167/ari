import 'package:ari/data/models/track.dart' as data;
import 'package:ari/domain/entities/track.dart' as domain;

/// data.Track → domain.Track 변환 확장 메서드
extension DataTrackMapper on data.Track {
  domain.Track toDomainTrack() {
    return domain.Track(
      trackId: id,
      trackTitle: trackTitle,
      artistName: artist,
      albumId: albumId,
      coverUrl: coverUrl,
      lyric: lyrics,
      composer: composer.split(', '), // string → list
      lyricist: lyricist.split(', '),
      trackFileUrl: trackFileUrl,
      trackNumber: 0,
      trackLikeCount: trackLikeCount,
      commentCount: 0,
      comments: [],
      createdAt: '',
      albumTitle: '', // 서버에 없으면 빈 값 처리
      genreName: '', // 서버에 없으면 빈 값 처리
    );
  }
}
