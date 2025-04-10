import 'package:ari/domain/repositories/album/album_like_repository.dart';

class ToggleAlbumLike {
  final AlbumLikeRepository repository;

  ToggleAlbumLike(this.repository);

  Future<bool> execute(int albumId, bool currentStatus) async {
    return await repository.toggleLike(albumId, currentStatus);
  }
}
