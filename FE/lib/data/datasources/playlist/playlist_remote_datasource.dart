/// 플레이리스트 데이터를 원격(API)에서 가져오거나, 트랙을 삭제하는 등
/// 원격 서버와 통신하는 로직의 추상화(Interface)
/// import 순환을 피하기 위해 구현파일을 import하지 않음
import 'package:ari/data/dto/playlist_create_request.dart';
import 'package:ari/data/models/playlist.dart';

abstract class IPlaylistRemoteDataSource {
  Future<List<Playlist>> fetchPlaylists();
  Future<Playlist> getPlaylistDetail(int playlistId);
  Future<Playlist> createPlaylist(PlaylistCreateRequest data);
  Future<void> addTrack(int playlistId, int trackId);
  Future<void> deleteTrack(int playlistId, int trackId);
  Future<void> deletePlaylist(int playlistId);
  Future<void> reorderTracks(int playlistId, List<int> trackOrder);
  Future<void> sharePlaylist(int playlistId);
  Future<List<Playlist>> fetchPopularPlaylists();
}
