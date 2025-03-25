class PlaylistCreateRequest {
  final String title;
  final bool isPublic;

  PlaylistCreateRequest({required this.title, required this.isPublic});

  Map<String, dynamic> toJson() => {'title': title, 'publicYn': isPublic};
}
