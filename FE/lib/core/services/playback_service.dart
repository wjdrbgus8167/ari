import 'package:ari/providers/global_providers.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ari/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/core/services/audio_service.dart';
import 'package:ari/data/models/api_response.dart';

class PlaybackService {
  final Dio dio;
  final AudioPlayer audioPlayer;

  PlaybackService({required this.dio, required this.audioPlayer});

  /// API를 호출하여 앨범의 특정 트랙 정보를 받아오고,
  /// AudioService를 사용해 트랙을 처음부터 재생하며 전역 상태(PlaybackState)를 업데이트합니다.
  Future<void> playTrack({
    required int albumId,
    required int trackId,
    required WidgetRef ref,
  }) async {
    final url = '/api/v1/albums/$albumId/tracks/$trackId';
    try {
      final response = await dio.post(url);
      print('[DEBUG] playTrack: 응답 상태 코드: ${response.statusCode}');
      print('[DEBUG] playTrack: 응답 데이터: ${response.data}');

      // ApiResponse를 이용해 JSON 파싱 (fromJsonT는 단순 Map<String, dynamic>로 처리)
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (response.statusCode == 200 &&
          response.data['status'] == 200 &&
          apiResponse.data != null) {
        final data = apiResponse.data!;
        final String trackFileUrl = data['trackFileUrl'];
        final String coverImageUrl = data['coverImageUrl'];
        final String title = data['title'];
        final String artist = data['artist'];
        final String lyrics = data['lyrics'];

        // AudioService를 사용해 API에서 받은 trackFileUrl로 트랙을 처음부터 재생 시작
        final audioService = ref.read(audioServiceProvider);
        await audioService.play(ref, trackFileUrl);
        print('[DEBUG] playTrack: 재생 시작됨');

        // PlaybackState 업데이트: 트랙 정보와 함께 currentTrackId(트랙 ID)와 trackUrl(트랙 파일 URL)을 저장
        ref
            .read(playbackProvider.notifier)
            .updateTrackInfo(
              trackTitle: title,
              artist: artist,
              coverImageUrl: coverImageUrl,
              lyrics: lyrics,
              currentTrackId: trackId,
              trackUrl: trackFileUrl,
            );
      } else {
        throw Exception('재생 API 호출 실패: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Dio 에러: ${e.message}');
    } catch (e) {
      throw Exception('에러 발생: $e');
    }
  }
}

final playbackServiceProvider = Provider<PlaybackService>(
  (ref) => PlaybackService(dio: ref.read(dioProvider), audioPlayer: AudioPlayer()),
);
