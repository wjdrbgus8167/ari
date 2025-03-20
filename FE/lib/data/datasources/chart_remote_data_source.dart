import 'package:dio/dio.dart';

// --dart-define으로 주입된 환경변수를 읽어옴
const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://j12c205.p.ssafy.io:8080',
);

// 차트 항목 모델 클래스
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

  factory ChartItem.fromJson(Map<String, dynamic> json) {
    return ChartItem(
      trackId: json['trackId'],
      trackTitle: json['trackTitle'],
      artist: json['artist'],
      coverImageUrl: json['coverImageUrl'],
      rank: json['rank'],
    );
  }
}

// Dio를 사용하여 차트 데이터를 가져오는 함수
Future<List<ChartItem>> fetchCharts() async {
  final dio = Dio();
  try {
    final response = await dio.get('$baseUrl/api/v1/charts');

    // 응답 상태 코드가 200이면 진행
    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      if (jsonResponse['status'] == 200) {
        final List charts = jsonResponse['data']['charts'];
        return charts.map((chart) => ChartItem.fromJson(chart)).toList();
      } else {
        throw Exception('API 에러: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('차트 데이터를 불러오지 못함. 상태 코드: ${response.statusCode}');
    }
  } on DioError catch (dioError) {
    // DioError를 잡아서 상세 오류 메시지 출력
    throw Exception('Dio 에러: ${dioError.message}');
  }
}
