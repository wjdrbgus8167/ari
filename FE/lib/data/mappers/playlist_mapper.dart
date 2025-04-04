import 'package:ari/data/models/playlist.dart' as data;
import 'package:ari/domain/entities/playlist.dart' as domain;
import 'package:ari/data/mappers/playlist_trackitem_mapper.dart';

//목록조회용 매퍼
domain.Playlist toEntity(data.Playlist model) {
  return domain.Playlist(
    id: model.id,
    title: model.title,
    isPublic: model.isPublic,
    shareCount: model.shareCount,
    trackCount: model.trackCount,
    tracks: [],
  );
}

// 상세조회용 매퍼퍼
domain.Playlist toEntityForDetail(data.Playlist model) {
  return domain.Playlist(
    id: model.id,
    title: model.title,
    isPublic: model.isPublic,
    shareCount: model.shareCount,
    trackCount: model.trackCount,
    tracks:
        model.tracks.map((trackModel) => toEntityTrack(trackModel)).toList(),
  );
}
