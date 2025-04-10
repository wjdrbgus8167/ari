import 'package:ari/providers/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/core/services/audio_service.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/domain/entities/track.dart' as domain;

import 'package:ari/domain/usecases/playback_permission_usecase.dart';

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
    required BuildContext context,
  }) async {
    final permissionResult = await ref
        .read(playbackPermissionUsecaseProvider)
        .check(albumId, trackId);

    if (permissionResult.isError) {
      throw Exception(permissionResult.message);
    }

    final url = '/api/v1/albums/$albumId/tracks/$trackId';
    try {
      final response = await dio.post(url);
      print('[DEBUG] playTrack: 응답 상태 코드: ${response.statusCode}');
      print('[DEBUG] playTrack: 응답 데이터: ${response.data}');

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

        final uniqueId = "track_$trackId";

        // Track 객체 생성
        final track = domain.Track(
          trackId: trackId,
          albumId: albumId,
          trackTitle: title,
          artistName: artist,
          lyric: lyrics,
          trackNumber: 0,
          commentCount: 0,
          lyricist: [''],
          composer: [''],
          comments: [],
          createdAt: DateTime.now().toString(),
          coverUrl: coverImageUrl,
          trackFileUrl: trackFileUrl,
          trackLikeCount: 0,
          albumTitle: '',
          genreName: '',
        );

        // ✅ AudioService를 통해 상태 갱신 + 재생만 수행 (중복 API 호출 X)
        final audioService = ref.read(audioServiceProvider);
        await audioService.playTrackDirectly(ref, track);

        print('[DEBUG] playTrack: 재생 시작됨');

        // 🎯 PlaybackState 동기화
        ref
            .read(playbackProvider.notifier)
            .updateTrackInfo(
              trackTitle: title,
              artist: artist,
              coverImageUrl: coverImageUrl,
              lyrics: lyrics,
              currentTrackId: trackId,
              albumId: albumId,
              trackUrl: trackFileUrl,
              isLiked: false,
              currentQueueItemId: uniqueId,
            );

        // 🎯 ListeningQueue에 기록
        final userId = ref.read(authUserIdProvider); // userId 가져오기

        ref
            .read(listeningQueueProvider(userId).notifier)
            .trackPlayed(track.toDataModel());
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
  (ref) => PlaybackService(
    dio: ref.watch(dioProvider),
    audioPlayer: ref.watch(audioPlayerProvider),
  ),
);
