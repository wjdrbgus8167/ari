import 'package:ari/core/utils/genre_utils.dart';
import 'package:ari/domain/entities/album.dart';

/// 선택된 장르에 따라 앨범 리스트 필터링
List<Album> filterAlbumsByGenre(List<Album> albums, Genre selectedGenre) {
  if (selectedGenre == Genre.all) return albums;
  for (final album in albums) {
    print(
      '[DEBUG] album.genre: "${album.genre}", 비교값: "${selectedGenre.displayName}"',
    );
  }
  return albums
      .where((album) => album.genre == selectedGenre.displayName)
      .toList();
}
