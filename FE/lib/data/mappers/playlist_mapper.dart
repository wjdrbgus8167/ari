// lib/data/mappers/playlist_mapper.dart
import 'package:ari/data/models/playlist.dart' as data;
import 'package:ari/domain/entities/playlist.dart' as domain;

domain.Playlist toEntity(data.Playlist model) {
  return domain.Playlist(
    id: model.playlistId,
    title: model.playlistTitle,
    isPublic: model.publicYn,
    shareCount: model.shareCount,
    tracks: [],
  );
}
