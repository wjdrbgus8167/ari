import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ari/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 오디오 재생 관련 기능을 제공하는 서비스 클래스임.
/// API 엔드포인트: api/v1/albums/{albumId}/tracks/{trackId}
class PlaybackService {
  final Dio dio;
  final AudioPlayer audioPlayer;

  PlaybackService({required this.dio, required this.audioPlayer});

  /// POST 메서드를 사용하여 앨범의 특정 트랙을 재생함.
  /// body는 보내지 않음.
  Future<void> playTrack({
    required int albumId,
    required int trackId,
    required WidgetRef ref,
  }) async {
    final url = '$baseUrl/api/v1/albums/$albumId/tracks/$trackId';
    try {
      final response = await dio.post(url);
      print('[DEBUG] playTrack: 응답 상태 코드: ${response.statusCode}');
      print('[DEBUG] playTrack: 응답 데이터: ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final data = response.data['data'];
        final String trackFileUrl = data['trackFileUrl'];
        final String coverImageUrl = data['coverImageUrl'];
        final String title = data['title'];
        final String artist = data['artist'];
        final String lyrics = data['lyrics'];

        // 트랙 파일 재생 시작
        await audioPlayer.play(UrlSource(trackFileUrl));
        print('[DEBUG] playTrack: 재생 시작됨');

        // PlaybackViewModel에 추가 정보 업데이트 (해당 메서드는 직접 구현 필요)
        ref
            .read(playbackProvider.notifier)
            .updateTrackInfo(
              trackTitle: title,
              artist: artist,
              coverImageUrl: coverImageUrl,
              lyrics: lyrics,
            );
      } else {
        throw Exception('재생 API 호출 실패: ${response.data['message']}');
      }
    } on DioException catch (e) {
      print('[ERROR] playTrack: Dio 에러: ${e.message}');
      rethrow;
    } catch (e) {
      print('[ERROR] playTrack: 에러 발생: $e');
      rethrow;
    }
  }
}
