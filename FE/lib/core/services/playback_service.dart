import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 빌드 시점에 주입된 환경변수에서 baseUrl 읽어옴 (const로 선언)
const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'https://j12c205.p.ssafy.io:8080',
);

/// 오디오 재생 관련 기능을 제공하는 서비스 클래스임.
/// API 엔드포인트: api/v1/albums/{albumId}/tracks/{trackId}/play
class PlaybackService {
  final Dio dio;
  final AudioPlayer audioPlayer;

  PlaybackService({required this.dio, required this.audioPlayer});

  /// 앨범의 특정 트랙을 재생하는 함수임.
  /// API를 호출해 응답에서 trackFileUrl을 추출하고, 오디오를 재생함.
  Future<void> playTrack({required int albumId, required int trackId}) async {
    final url = '$baseUrl/api/v1/albums/$albumId/tracks/$trackId/play';
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200 && response.data['status'] == 200) {
        final data = response.data['data'];
        final String trackFileUrl = data['trackFileUrl'];

        // 네트워크 URL을 통해 오디오 재생
        await audioPlayer.play(UrlSource(trackFileUrl));
      } else {
        throw Exception('재생 API 호출 실패: ${response.data['message']}');
      }
    } on DioError catch (e) {
      throw Exception('Dio 에러: ${e.message}');
    }
  }
}

/// Dio 인스턴스를 전역에서 제공함.
final dioProvider = Provider<Dio>((ref) => Dio());

/// AudioPlayer 인스턴스를 전역에서 제공함.
final audioPlayerProvider = Provider<AudioPlayer>((ref) => AudioPlayer());

/// PlaybackService를 앱 전역에서 재생 기능을 사용할 수 있도록 Provider로 등록함.
final playbackServiceProvider = Provider<PlaybackService>((ref) {
  return PlaybackService(
    dio: ref.watch(dioProvider),
    audioPlayer: ref.watch(audioPlayerProvider),
  );
});
