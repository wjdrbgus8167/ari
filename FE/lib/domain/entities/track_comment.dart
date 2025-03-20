class TrackComment {
  final int id;
  final int trackId;
  final String nickname;
  final String content;
  final String timestamp; // 트랙 내 타임스탬프 (예: "01:25")
  final DateTime createdAt; // 코멘트 생성 시간

  TrackComment({
    required this.id,
    required this.trackId,
    required this.nickname,
    required this.content,
    required this.timestamp,
    required this.createdAt,
  });
}