import '../../data/models/album.dart';
import './genre_utils.dart'; // ✅ Genre 변환 함수 활용

/// 선택된 장르에 따라 앨범 리스트 필터링
List<Album> filterAlbumsByGenre(List<Album> albums, Genre selectedGenre) {
  if (selectedGenre == Genre.all) return albums; // "전체" 선택 시 모든 앨범 반환

  return albums
      .where((album) => album.genre.toLowerCase() == selectedGenre.name)
      .toList();
}
