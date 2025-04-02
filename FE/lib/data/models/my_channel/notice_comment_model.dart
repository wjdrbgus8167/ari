/// 공지사항 댓글 모델
/// 공지사항 댓글 API 응답을 처리하기 위한 데이터 모델 클래스
class NoticeComment {
  final int commentId;
  final int memberId;
  final String memberName;
  final String? profileImageUrl;
  final String content;
  final String createdAt;
  
  // 로컬에서만 사용하는 속성 (본인 댓글 여부 확인용)
  bool isMine = false;
  
  // 로컬에서만 사용하는 속성 (댓글 편집 상태 관리용)
  bool isEditing = false;

  NoticeComment({
    required this.commentId,
    required this.memberId,
    required this.memberName,
    this.profileImageUrl,
    required this.content,
    required this.createdAt,
    this.isMine = false,
    this.isEditing = false,
  });

  /// JSON 데이터로부터 모델 객체 생성
  factory NoticeComment.fromJson(Map<String, dynamic> json) {
    return NoticeComment(
      commentId: json['commentId'] ?? 0,
      memberId: json['memberId'] ?? 0, 
      memberName: json['memberName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  /// 모델 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'memberId': memberId,
      'memberName': memberName,
      'profileImageUrl': profileImageUrl,
      'content': content,
      'createdAt': createdAt,
    };
  }
  
  /// 댓글 수정 시 사용할 복사본 생성 메서드
  NoticeComment copyWith({
    int? commentId,
    int? memberId,
    String? memberName,
    String? profileImageUrl,
    String? content,
    String? createdAt,
    bool? isMine,
    bool? isEditing,
  }) {
    return NoticeComment(
      commentId: commentId ?? this.commentId,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

/// 공지사항 댓글 응답 모델
/// API에서 반환되는 댓글 목록과 개수 정보를 포함하는 클래스
class NoticeCommentsResponse {
  final List<NoticeComment> comments;
  final int commentCount;

  NoticeCommentsResponse({
    required this.comments,
    required this.commentCount,
  });

  /// JSON 데이터로부터 모델 객체 생성
  factory NoticeCommentsResponse.fromJson(Map<String, dynamic> json) {
    final commentsList = json['comments'] as List<dynamic>? ?? [];
    
    return NoticeCommentsResponse(
      comments: commentsList
          .map((commentJson) => NoticeComment.fromJson(commentJson))
          .toList(),
      commentCount: json['commentCount'] ?? 0,
    );
  }
}