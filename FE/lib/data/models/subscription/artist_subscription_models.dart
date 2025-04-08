// 아티스트 기본 정보 모델
class Artist {
  final int? artistId; // null 허용으로 변경
  final String artistNickname;

  Artist({
    this.artistId, // required 제거
    required this.artistNickname,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      artistId: json['artistId'], // 존재하지 않으면 null 처리
      artistNickname: json['artistNickName'], // 'N'이 대문자
    );
  }
}

// 구독 항목 모델 (수정 필요 없음)
class ArtistSubscriptionDetail {
  final String planType;
  final String startedAt;
  final String endedAt;
  final double settlement;

  ArtistSubscriptionDetail({
    required this.planType,
    required this.startedAt,
    required this.endedAt,
    required this.settlement,
  });

  factory ArtistSubscriptionDetail.fromJson(Map<String, dynamic> json) {
    return ArtistSubscriptionDetail(
      planType: json['planType'],
      startedAt: json['startedAt'],
      endedAt: json['endedAt'],
      settlement: json['settlement'] is int 
          ? (json['settlement'] as int).toDouble() 
          : json['settlement'],
    );
  }
}

// 아티스트 상세 정보 모델
class ArtistDetail {
  final String artistNickname;
  final String? profileImageUrl; // null 허용으로 변경
  final double totalSettlement;
  final int totalStreamingCount;
  final List<ArtistSubscriptionDetail> subscriptions;

  ArtistDetail({
    required this.artistNickname,
    this.profileImageUrl, // required 제거
    required this.totalSettlement,
    required this.totalStreamingCount,
    required this.subscriptions,
  });

  factory ArtistDetail.fromJson(Map<String, dynamic> json) {
    return ArtistDetail(
      artistNickname: json['artistNickName'], // 'N'이 대문자
      profileImageUrl: json['profileImageUrl'],
      totalSettlement: json['totalSettlement'] is int 
          ? (json['totalSettlement'] as int).toDouble() 
          : json['totalSettlement'],
      totalStreamingCount: json['totalStreamingCount'],
      subscriptions: (json['subscriptions'] as List)
          .map((item) => ArtistSubscriptionDetail.fromJson(item))
          .toList(),
    );
  }
}

// 아티스트 목록 응답 모델 (수정 필요 없음)
class ArtistsResponse {
  final List<Artist> artists;

  ArtistsResponse({
    required this.artists,
  });

  factory ArtistsResponse.fromJson(Map<String, dynamic> json) {
    return ArtistsResponse(
      artists: (json['artists'] as List)
          .map((artist) => Artist.fromJson(artist))
          .toList(),
    );
  }
}