/// 팬톡에 포함된 트랙 정보 담는 클래스
class FanTalkTrack {
  final int trackId;
  final String trackName;
  final String artist;
  final String coverImageUrl;

  FanTalkTrack({
    required this.trackId,
    required this.trackName,
    required this.artist,
    required this.coverImageUrl,
  });

  /// [return] 생성된 FanTalkTrack 객체
  factory FanTalkTrack.fromJson(Map<String, dynamic> json) {
    return FanTalkTrack(
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? '',
      artist: json['artist'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
    );
  }
}

/// 팬톡 정보 담긴 모델 클래스
class FanTalk {
  final int fantalkId;
  final int memberId;
  final String memberName;
  final String profileImageUrl;
  final String content;
  final String? fantalkImageUrl;
  final FanTalkTrack? track;
  final String createdAt;

  FanTalk({
    required this.fantalkId,
    required this.memberId,
    required this.memberName,
    required this.profileImageUrl,
    required this.content,
    this.fantalkImageUrl,
    this.track,
    required this.createdAt,
  });

  /// [return] 생성된 FanTalk 객체
  factory FanTalk.fromJson(Map<String, dynamic> json) {
    return FanTalk(
      fantalkId: json['fantalkId'] ?? 0,
      memberId: json['memberId'] ?? 0,
      memberName: json['memberName'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      content: json['content'] ?? '',
      fantalkImageUrl: json['fantalkImageUrl'],
      track: json['track'] != null ? FanTalkTrack.fromJson(json['track']) : null,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

/// 팬톡 목록 및 카운트 정보 담긴 모델 클래스
class FanTalkResponse {
  final List<FanTalk> fantalks;
  final int fantalkCount;

  FanTalkResponse({
    required this.fantalks,
    required this.fantalkCount,
  });

  /// [return] 생성된 FanTalkResponse 객체
  factory FanTalkResponse.fromJson(Map<String, dynamic> json) {
    final fantalksList = json['fantalks'] as List<dynamic>? ?? [];
    
    return FanTalkResponse(
      fantalks: fantalksList
          .map((fantalkJson) => FanTalk.fromJson(fantalkJson))
          .toList(),
      fantalkCount: json['fantalkCount'] ?? 0,
    );
  }
}