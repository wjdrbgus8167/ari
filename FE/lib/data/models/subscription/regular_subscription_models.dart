// 구독 주기 모델
class SubscriptionCycle {
  final int cycleId;
  final String startedAt;
  final String endedAt;
  
  SubscriptionCycle({
    required this.cycleId,
    required this.startedAt,
    required this.endedAt,
  });
  
  factory SubscriptionCycle.fromJson(Map<String, dynamic> json) {
    return SubscriptionCycle(
      cycleId: json['cycleId'],
      startedAt: json['startedAt'],
      endedAt: json['endedAt'],
    );
  }
  
  // 표시용 텍스트 (드롭다운에 표시할 내용)
  String get displayText {
    return '$startedAt ~ $endedAt';
  }
}

// 아티스트 정산 항목 모델
class ArtistSettlement {
  final String artistNickname;
  final String profileImageUrl;
  final int streamingCount;
  final double settlement;
  
  ArtistSettlement({
    required this.artistNickname,
    required this.profileImageUrl,
    required this.streamingCount,
    required this.settlement,
  });
  
  factory ArtistSettlement.fromJson(Map<String, dynamic> json) {
    return ArtistSettlement(
      artistNickname: json['artistNickname'],
      profileImageUrl: json['profileImageUrl'],
      streamingCount: json['streamingCount'],
      settlement: json['settlement'] is int 
                ? (json['settlement'] as int).toDouble() 
                : json['settlement'],
    );
  }
}

// 구독 상세 정보 모델
class RegularSubscriptionDetail {
  final double price;
  final List<ArtistSettlement> settlements;
  
  RegularSubscriptionDetail({
    required this.price,
    required this.settlements,
  });
  
  factory RegularSubscriptionDetail.fromJson(Map<String, dynamic> json) {
    return RegularSubscriptionDetail(
      price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'],
      settlements: (json['settlements'] as List)
          .map((item) => ArtistSettlement.fromJson(item))
          .toList(),
    );
  }
}