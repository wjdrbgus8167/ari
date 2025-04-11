// lib/data/mappers/playlist_trackitem_mapper.dart
import 'package:ari/data/models/playlist_trackitem.dart' as data;
import 'package:ari/domain/entities/playlist_trackitem.dart' as domain;

domain.PlaylistTrackItem toEntityTrack(data.PlaylistTrackItem model) {
  return domain.PlaylistTrackItem(
    artistId: model.artistId,
    trackOrder: model.trackOrder,
    trackId: model.trackId,
    artist: model.artist,
    coverImageUrl: model.coverImageUrl,
    composer: model.composer,
    lyricist: model.lyricist,
    lyrics: model.lyrics,
    trackFileUrl: model.trackFileUrl,
    trackLikeCount: model.trackLikeCount,
    trackNumber: model.trackNumber,
    trackTitle: model.trackTitle,
    albumId: model.albumId,
  );
}
