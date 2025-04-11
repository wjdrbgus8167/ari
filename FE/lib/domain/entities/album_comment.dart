class AlbumComment {
  /// 댓글의 고유 식별자
  final int id;
  
  /// 댓글이 달린 앨범의의 ID
  final int memberId;
  
  /// 댓글 작성자의 닉네임
  final String nickname;
  
  /// 댓글 내용
  final String content;
  
  /// 댓글 작성 날짜 및 시간 (ISO 8601 형식)
  final String createdAt;

  final String userAvatar;

  /// 댓글 생성자
  const AlbumComment({
      required this.id,
      required this.memberId,
      required this.nickname,
      required this.content,
      required this.createdAt,
      required this.userAvatar,
  });
}