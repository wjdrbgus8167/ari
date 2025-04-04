//api응답에서 각 차트 항목의 정보를 읽어와서 객체로 변환될때 사용

class ChartItem {
  final int trackId;
  final int albumId;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;
  final int rank;
  final String trackFileUrl;

  ChartItem({
    required this.trackId,
    required this.albumId,
    required this.trackTitle,
    required this.artist,
    required this.coverImageUrl,
    required this.rank,
    required this.trackFileUrl,
  });

  // JSON 데이터를 받아 ChartItem 객체로 변환하는 팩토리 생성자
  factory ChartItem.fromJson(Map<String, dynamic> json) {
    return ChartItem(
      trackId: json['trackId'],
      albumId: json['albumId'],
      trackTitle: json['trackTitle'],
      artist: json['artist'],
      coverImageUrl: json['coverImageUrl'],
      trackFileUrl: json['trackFileUrl'],
      rank: json['rank'],
    );
  }
}
