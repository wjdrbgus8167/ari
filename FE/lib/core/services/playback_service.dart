import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';

// 빌드 시점에 주입된 환경변수에서 baseUrl 읽어옴 (const로 선언)
const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'https://ari-music.duckdns.org',
);

/// 오디오 재생 관련 기능을 제공하는 서비스 클래스임.
/// API 엔드포인트: api/v1/albums/{albumId}/tracks/{trackId}/play
class PlaybackService {
  final Dio dio;
  final AudioPlayer audioPlayer;

  PlaybackService({required this.dio, required this.audioPlayer});

  /// POST 메서드를 사용하여 앨범의 특정 트랙을 재생함.
  /// body는 보내지 않음.
  Future<void> playTrack({required int albumId, required int trackId}) async {
    final url = '$baseUrl/api/v1/albums/$albumId/tracks/$trackId/play';
    try {
      final response = await dio.post(url);
      if (response.statusCode == 200 && response.data['status'] == 200) {
        final data = response.data['data'];
        final String trackFileUrl = data['trackFileUrl'];
        await audioPlayer.play(UrlSource(trackFileUrl));
      } else {
        throw Exception('재생 API 호출 실패: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Dio 에러: ${e.message}');
    }
  }
}
