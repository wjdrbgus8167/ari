import 'package:ari/data/models/album.dart';

/// 한글 장르명을 영어로 매핑하는 함수
String mapGenre(String genre) {
  switch (genre) {
    case "재즈":
      return "jazz";
    case "힙합":
      return "hiphop";
    case "밴드":
      return "band";
    case "알앤비":
      return "rnb";
    case "어쿠스틱":
      return "acoustic";
    case "전체":
      return "전체";
    default:
      return genre;
  }
}

/// 선택된 장르에 따라 앨범 리스트를 필터링하는 함수
List<Album> filterAlbumsByGenre(List<Album> albums, String selectedGenre) {
  if (selectedGenre == "전체") {
    return albums;
  }
  return albums
      .where(
        (album) =>
            album.genre.toLowerCase() == mapGenre(selectedGenre).toLowerCase(),
      )
      .toList();
}
