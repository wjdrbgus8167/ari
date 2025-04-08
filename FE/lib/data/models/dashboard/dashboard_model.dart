// 아티스트 대시보드 데이터 모델 (Flutter/Dart)

class DailySubscriberCount {
  final String date;          // 날짜 (YY.MM.DD 형식)
  final int subscriberCount;  // 해당 날짜의 구독자 수

  DailySubscriberCount({
    required this.date,
    required this.subscriberCount,
  });

  factory DailySubscriberCount.fromJson(Map<String, dynamic> json) {
    return DailySubscriberCount(
      date: json['date'],
      subscriberCount: json['subscriberCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'subscriberCount': subscriberCount,
    };
  }
}

class DailySettlement {
  final String date;        // 날짜 (YY.MM.DD 형식)
  final double settlement;  // 해당 날짜의 정산 금액

  DailySettlement({
    required this.date,
    required this.settlement,
  });

  factory DailySettlement.fromJson(Map<String, dynamic> json) {
    return DailySettlement(
      date: json['date'],
      settlement: json['settlement'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'settlement': settlement,
    };
  }
}

class Album {
  final String albumTitle;     // 앨범 제목
  final String coverImageUrl;  // 앨범 커버 이미지 URL
  final int trackCount;        // 앨범 내 트랙 수

  Album({
    required this.albumTitle,
    required this.coverImageUrl,
    required this.trackCount,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      albumTitle: json['albumTitle'],
      coverImageUrl: json['coverImageUrl'],
      trackCount: json['trackCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'albumTitle': albumTitle,
      'coverImageUrl': coverImageUrl,
      'trackCount': trackCount,
    };
  }
}

class ArtistDashboardData {
  final String walletAddress;           // 아티스트 지갑 주소
  final int subscriberCount;            // 전체 구독자 수
  final int totalStreamingCount;        // 전체 스트리밍 횟수
  final int todayStreamingCount;        // 오늘 스트리밍 횟수
  final int streamingDiff;              // 전일 대비 스트리밍 증감
  final int todayNewSubscriberCount;    // 오늘 신규 구독자 수
  final int newSubscriberDiff;          // 전일 대비 신규 구독자 증감
  final double todaySettlement;         // 오늘 정산 금액
  final double settlementDiff;          // 전일 대비 정산 금액 증감
  final int todayNewSubscribeCount;     // 오늘 신규 구독 수
  final List<Album> albums;             // 아티스트의 앨범 리스트
  final List<DailySubscriberCount> dailySubscriberCounts;  // 일간 구독자 수 추이
  final List<DailySettlement> dailySettlement;             // 일간 정산 금액 추이

  ArtistDashboardData({
    required this.walletAddress,
    required this.subscriberCount,
    required this.totalStreamingCount,
    required this.todayStreamingCount,
    required this.streamingDiff,
    required this.todayNewSubscriberCount,
    required this.newSubscriberDiff,
    required this.todaySettlement,
    required this.settlementDiff,
    required this.todayNewSubscribeCount,
    required this.albums,
    required this.dailySubscriberCounts,
    required this.dailySettlement,
  });

  factory ArtistDashboardData.fromJson(Map<String, dynamic> json) {
    return ArtistDashboardData(
      walletAddress: json['walletAddress'],
      subscriberCount: json['subscriberCount'],
      totalStreamingCount: json['totalStreamingCount'],
      todayStreamingCount: json['todayStreamingCount'],
      streamingDiff: json['streamingDiff'],
      todayNewSubscriberCount: json['todayNewSubscriberCount'],
      newSubscriberDiff: json['newSubscriberDiff'],
      todaySettlement: json['todaySettlement'].toDouble(),
      settlementDiff: json['settlementDiff'].toDouble(),
      todayNewSubscribeCount: json['todayNewSubscribeCount'],
      albums: (json['albums'] as List)
          .map((albumJson) => Album.fromJson(albumJson))
          .toList(),
      dailySubscriberCounts: (json['dailySubscriberCounts'] as List)
          .map((countJson) => DailySubscriberCount.fromJson(countJson))
          .toList(),
      dailySettlement: (json['dailySettlement'] as List)
          .map((settlementJson) => DailySettlement.fromJson(settlementJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletAddress': walletAddress,
      'subscriberCount': subscriberCount,
      'totalStreamingCount': totalStreamingCount,
      'todayStreamingCount': todayStreamingCount,
      'streamingDiff': streamingDiff,
      'todayNewSubscriberCount': todayNewSubscriberCount,
      'newSubscriberDiff': newSubscriberDiff,
      'todaySettlement': todaySettlement,
      'settlementDiff': settlementDiff,
      'todayNewSubscribeCount': todayNewSubscribeCount,
      'albums': albums.map((album) => album.toJson()).toList(),
      'dailySubscriberCounts': dailySubscriberCounts
          .map((count) => count.toJson())
          .toList(),
      'dailySettlement': dailySettlement
          .map((settlement) => settlement.toJson())
          .toList(),
    };
  }
}