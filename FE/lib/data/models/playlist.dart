class Playlist {
  final String id;
  final String title;
  final String coverUrl; // 플레이리스트 이미지
  final List<String> songIds; // 플레이리스트에 포함된 곡들의 ID

  Playlist({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.songIds,
  });
}
