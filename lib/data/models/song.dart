class Song {
  final String id;
  final String title;
  final String artist;
  final String albumId;  // 어떤 앨범에 속하는지
  final String audioUrl; // 실제 재생 URL

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumId,
    required this.audioUrl,
  });
}
