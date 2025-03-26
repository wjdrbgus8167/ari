class Playlist {
  final int id;
  final String title;
  final bool isPublic;
  final int trackCount;

  const Playlist({
    required this.id,
    required this.title,
    required this.isPublic,
    required this.trackCount,
  });
}
