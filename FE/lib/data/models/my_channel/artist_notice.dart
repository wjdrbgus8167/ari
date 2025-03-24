class ArtistNotice {
  final int noticeId;
  final String noticeContent;
  final String createdAt;

  ArtistNotice({
    required this.noticeId,
    required this.noticeContent,
    required this.createdAt,
  });

  factory ArtistNotice.fromJson(Map<String, dynamic> json) {
    return ArtistNotice(
      noticeId: json['noticeId'] ?? 0,
      noticeContent: json['noticeContent'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noticeId': noticeId,
      'noticeContent': noticeContent,
      'createdAt': createdAt,
    };
  }
}

/// 아티스트 공지사항 목록, 카운트 정보 담는 클래스
class ArtistNoticeResponse {
  final List<ArtistNotice> notices;
  final int noticeCount;

  ArtistNoticeResponse({
    required this.notices,
    required this.noticeCount,
  });

  factory ArtistNoticeResponse.fromJson(Map<String, dynamic> json) {
    final noticesList = json['notices'] as List<dynamic>? ?? [];
    
    return ArtistNoticeResponse(
      notices: noticesList
          .map((noticeJson) => ArtistNotice.fromJson(noticeJson))
          .toList(),
      noticeCount: json['noticeCount'] ?? 0,
    );
  }
}