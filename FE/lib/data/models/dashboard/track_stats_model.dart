class TrackStats {
  final String trackTitle;
  final String coverImageUrl;
  final int monthlyStreamingCount;
  final int totalStreamingCount;

  TrackStats({
    required this.trackTitle,
    required this.coverImageUrl,
    required this.monthlyStreamingCount,
    required this.totalStreamingCount,
  });

  factory TrackStats.fromJson(Map<String, dynamic> json) {
    return TrackStats(
      trackTitle: json['trackTitle'],
      coverImageUrl: json['coverImageUrl'],
      monthlyStreamingCount: json['monthlyStreamingCount'],
      totalStreamingCount: json['totalStreamingCount'],
    );
  }
}

// 트랙 목록을 파싱하는 메서드가 필요한 경우 추가
class TrackStatsList {
  final List<TrackStats> tracks;

  TrackStatsList({
    required this.tracks,
  });

  factory TrackStatsList.fromJson(Map<String, dynamic> json) {
    return TrackStatsList(
      tracks: (json['tracks'] as List)
          .map((track) => TrackStats.fromJson(track))
          .toList(),
    );
  }
}