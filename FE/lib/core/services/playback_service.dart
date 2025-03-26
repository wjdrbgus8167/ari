import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ari/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/core/services/audio_service.dart';
import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/api_response.dart';

// PlaybackService은 api 호출을 통해서 트랙 정보를 받아옴
// AudioService를 사용해서 트랙을 처음부터 재생하고 전역상태(PlaybackState)를 업데이트
class PlaybackService {
  final Dio dio;
  final AudioPlayer audioPlayer;

  PlaybackService({required this.dio, required this.audioPlayer});

  // api 호출 후 앨범 속 특정 트랙 정보를 가져옴옴
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

      // ApiResponse를 이용해 JSON 파싱 (fromJsonT는 단순 Map으로 반환하도록 처리)
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final data = apiResponse.data!;
        final String trackFileUrl = data['trackFileUrl'];
        final String coverImageUrl = data['coverImageUrl'];
        final String title = data['title'];
        final String artist = data['artist'];
        final String lyrics = data['lyrics'];

        // AudioService를 사용해 API에서 받은 trackFileUrl로 트랙 처음부터 재생 시작
        final audioService = ref.read(audioServiceProvider);
        await audioService.play(ref, trackFileUrl);
        print('[DEBUG] playTrack: 재생 시작됨');

        // PlaybackState 업데이트: 트랙 정보와 함께 trackFileUrl도 저장 (currentTrackId는 trackId 사용)
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
        throw Failure.fromApiResponse(apiResponse);
      }
    } on DioException catch (e) {
      throw Failure.fromDioException(e);
    } catch (e) {
      throw Failure.fromException(e as Exception);
    }
  }
}

//PlaybackService 인스턴스를 전역적으로 제공하는 provider
final playbackServiceProvider = Provider<PlaybackService>(
  (ref) => PlaybackService(dio: Dio(), audioPlayer: AudioPlayer()),
);
