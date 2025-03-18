/// 장르 Enum
enum Genre { all, hiphop, jazz, band, rnb, acoustic }

/// `Genre` → 한글 변환
extension GenreExtension on Genre {
  String get displayName {
    switch (this) {
      case Genre.hiphop:
        return "힙합";
      case Genre.jazz:
        return "재즈";
      case Genre.band:
        return "밴드";
      case Genre.rnb:
        return "알앤비";
      case Genre.acoustic:
        return "어쿠스틱";
      case Genre.all:
        return "전체";
    }
  }
}

///`String` → `Genre` 변환
Genre getGenreFromDisplayName(String name) {
  return Genre.values.firstWhere(
    (g) => g.displayName == name,
    orElse: () => Genre.all,
  );
}
