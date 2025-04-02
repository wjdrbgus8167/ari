class PlaylistCreateRequest {
  final String title;
  // publicYn은 제거하거나 필요 시 별도의 필드로 추가

  PlaylistCreateRequest({required this.title});

  Map<String, dynamic> toJson() => {'playlistTitle': title};
}
