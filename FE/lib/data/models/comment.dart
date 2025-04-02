class Comment {
  final int commentId;
  final int memberId;
  final String nickname;
  final String? profileImageUrl;
  final String content;
  final String? timestamp;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.memberId,
    required this.nickname,
    this.profileImageUrl,
    required this.content,
    this.timestamp,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'],
      memberId: json['memberId'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
      content: json['content'],
      timestamp: json['timestamp'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
