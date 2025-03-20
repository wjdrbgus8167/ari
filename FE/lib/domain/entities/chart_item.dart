//api응답에서 각 차트 항목의 정보를 읽어와서 객체로 변환될때 사용

class ChartItem {
  final int trackId;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;
  final int rank;

  ChartItem({
    required this.trackId,
    required this.trackTitle,
    required this.artist,
    required this.coverImageUrl,
    required this.rank,
  });

  // JSON 데이터를 받아 ChartItem 객체로 변환하는 팩토리 생성자
  factory ChartItem.fromJson(Map<String, dynamic> json) {
    return ChartItem(
      trackId: json['trackId'],
      trackTitle: json['trackTitle'],
      artist: json['artist'],
      coverImageUrl: json['coverImageUrl'],
      // coverImageUrl: 'assets/images/default_album_image.png',
      rank: json['rank'],
    );
  }
}
