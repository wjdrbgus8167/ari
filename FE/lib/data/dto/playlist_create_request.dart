class PlaylistCreateRequest {
  final String title;
  final bool publicYn;

  PlaylistCreateRequest({required this.title, required this.publicYn});

  Map<String, dynamic> toJson() => {
    'playlistTitle': title,
    'publicYn': publicYn,
  };
}
