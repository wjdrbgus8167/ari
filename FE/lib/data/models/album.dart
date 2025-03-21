class Album {
  final int id;
  final String title;
  final String genre;
  final String artist;
  final String coverUrl; // 앨범 커버 이미지 URL
  final DateTime releaseDate;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    this.coverUrl = '', // 기본값 빈 문자열 또는 기본 URL
    required this.releaseDate,
  });
}
