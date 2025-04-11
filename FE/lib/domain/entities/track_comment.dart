class TrackComment {
  final int memberId;
  final int commentId;
  final String nickname;
  final String content;
  final String timestamp; // 트랙 내 타임스탬프 (예: "01:25")
  final String createdAt; // 코멘트 생성 시간

  TrackComment({
    required this.memberId,
    required this.commentId,
    required this.nickname,
    required this.content,
    required this.timestamp,
    required this.createdAt,
  });

  factory TrackComment.fromJson(Map<String, dynamic> json) {
    return TrackComment(
      memberId:
          json['memberId'] is int
              ? json['memberId']
              : int.tryParse(json['memberId']?.toString() ?? '0') ?? 0,
      commentId:
          json['commentId'] is int
              ? json['commentId']
              : int.tryParse(json['commentId']?.toString() ?? '0') ?? 0,
      nickname: json['nickname'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
