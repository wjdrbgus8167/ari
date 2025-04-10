class MonthlySubscriberCount {
  final String month;          // 날짜 (YYYY-MM-DD 또는 YY.MM.DD 형식)
  final int subscriberCount;  // 해당 날짜의 구독자 수

  MonthlySubscriberCount({
    required this.month,
    required this.subscriberCount,
  });

  factory MonthlySubscriberCount.fromJson(Map<String, dynamic> json) {
    return MonthlySubscriberCount(
      month: json['month'],
      subscriberCount: json['subscriberCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'subscriberCount': subscriberCount,
    };
  }
}

class HourlySubscriberCount {
  final String hour;        // 월 (YY.MM 형식)
  final int subscriberCount; // 해당 월의 구독자 수

  HourlySubscriberCount({
    required this.hour,
    required this.subscriberCount,
  });

  factory HourlySubscriberCount.fromJson(Map<String, dynamic> json) {
    return HourlySubscriberCount(
      hour: json['hour'],
      subscriberCount: json['subscriberCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'subscriberCount': subscriberCount,
    };
  }
}

class HourlySettlement {
  final String hour;        // 날짜 (YY.MM.DD 형식)
  final double settlement;  // 해당 날짜의 정산 금액

  HourlySettlement({
    required this.hour,
    required this.settlement,
  });

  factory HourlySettlement.fromJson(Map<String, dynamic> json) {
    return HourlySettlement(
      hour: json['hour'],
      settlement: json['settlement'] is int 
          ? (json['settlement'] as int).toDouble() 
          : json['settlement'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'settlement': settlement,
    };
  }
}

class Album {
  final String albumTitle;     // 앨범 제목
  final String coverImageUrl;  // 앨범 커버 이미지 URL
  final int totalStreaming;    // 앨범 총 스트리밍 횟수

  Album({
    required this.albumTitle,
    required this.coverImageUrl,
    required this.totalStreaming,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      albumTitle: json['albumTitle'],
      coverImageUrl: json['coverImageUrl'],
      totalStreaming: json['totalStreaming'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'albumTitle': albumTitle,
      'coverImageUrl': coverImageUrl,
      'totalStreaming': totalStreaming,
    };
  }
}

class ArtistDashboardData {
  final String? walletAddress;           // 아티스트 지갑 주소
  final int subscriberCount;             // 전체 구독자 수
  final int totalStreamingCount;         // 전체 스트리밍 횟수
  final int todayStreamingCount;         // 오늘 스트리밍 횟수
  final int streamingDiff;               // 전일 대비 스트리밍 증감
  final int todayNewSubscriberCount;     // 오늘 신규 구독자 수
  final int newSubscriberDiff;           // 전일 대비 신규 구독자 증감
  final double todaySettlement;          // 오늘 정산 금액
  final double settlementDiff;           // 전일 대비 정산 금액 증감
  final int todayNewSubscribeCount;      // 오늘 신규 구독 수
  final List<Album> albums;              // 아티스트의 앨범 리스트
  final List<MonthlySubscriberCount> dailySubscriberCounts;  // 일간 구독자 수 추이
  final List<HourlySettlement> hourlySettlement;  // 일간 정산 금액 추이
  final List<HourlySubscriberCount> hourlySubscriberCounts; // 월간 구독자 수 추이

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
    required this.hourlySettlement, 
    required this.hourlySubscriberCounts,
  });

  factory ArtistDashboardData.fromJson(Map<String, dynamic> json) {
    return ArtistDashboardData(
      walletAddress: json['walletAddress'],
      subscriberCount: json['subscriberCount'],
      totalStreamingCount: json['totalStreamingCount'],
      todayStreamingCount: json['todayStreamingCount'],
      streamingDiff: json['streamingDiff'],
      todayNewSubscriberCount: json['thisMonthNewSubscriberCount'], // API 응답 필드명 수정
      newSubscriberDiff: json['newSubscriberDiff'],
      todaySettlement: json['todaySettlement'] is int 
          ? (json['todaySettlement'] as int).toDouble() 
          : json['todaySettlement'].toDouble(),
      settlementDiff: json['settlementDiff'] is int 
          ? (json['settlementDiff'] as int).toDouble() 
          : json['settlementDiff'].toDouble(),
      todayNewSubscribeCount: json['todayNewSubscribeCount'],
      albums: (json['albums'] as List)
          .map((albumJson) => Album.fromJson(albumJson))
          .toList(),
      dailySubscriberCounts: (json['monthlySubscriberCounts'] as List)
          .map((countJson) => MonthlySubscriberCount.fromJson(countJson))
          .toList(),
      hourlySettlement: (json['hourlySettlement'] as List)
          .map((settlementJson) => HourlySettlement.fromJson(settlementJson))
          .toList(),
      hourlySubscriberCounts: (json['hourlySubscriberCounts'] as List)
          .map((countJson) => HourlySubscriberCount.fromJson(countJson))
          .toList(),
    );
  }
}