import 'package:ari/data/datasources/local/local_listening_queue_datasource.dart';
import 'package:ari/domain/usecases/playback_permission_usecase.dart';
import 'package:ari/presentation/viewmodels/listening_queue_viewmodel.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:dio/dio.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/data/models/track.dart' as data;

class AudioService {
  final AudioPlayer audioPlayer = AudioPlayer();
  final ConcatenatingAudioSource _playlistSource = ConcatenatingAudioSource(
    children: [],
  );

  Stream<Duration> get onPositionChanged => audioPlayer.positionStream;
  Stream<Duration?> get onDurationChanged => audioPlayer.durationStream;

  AudioService() {
    _initializePlayer();
  }

  void _initializePlayer() {
    audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await audioPlayer.seekToNext();
        await audioPlayer.play();
      }
    });
  }

  Future<void> playFullTrackList({
    required WidgetRef ref,
    required BuildContext context,
    required List<Track> tracks,
  }) async {
    if (tracks.isEmpty) {
      context.showToast('재생할 트랙이 없습니다.');
      return;
    }

    final permissionUsecase = ref.read(playbackPermissionUsecaseProvider);
    final dio = ref.read(dioProvider);
    final allowedTracks = <Track>[];

    for (final track in tracks) {
      final result = await permissionUsecase.check(
        track.albumId,
        track.trackId,
      );
      if (!result.isError) {
        allowedTracks.add(track);
      }
    }

    if (allowedTracks.isEmpty) {
      context.showToast('⛔ 재생 가능한 트랙이 없습니다.');
      return;
    }

    final firstTrack = allowedTracks.first;

    try {
      final track = await _fetchPlayableTrack(
        ref,
        dio,
        firstTrack.albumId,
        firstTrack.trackId,
        context,
      );
      await _playAndSetState(ref, track);
    } catch (e) {
      context.showToast(e.toString());
      return;
    }

    _playlistSource.clear();
    for (final track in allowedTracks) {
      _playlistSource.add(AudioSource.uri(Uri.parse(track.trackFileUrl ?? '')));
    }
    await audioPlayer.setAudioSource(_playlistSource, initialIndex: 0);
  }

  Future<void> playSingleTrackWithPermission(
    WidgetRef ref,
    Track track,
    BuildContext context,
  ) async {
    final dio = ref.read(dioProvider);
    final permissionUsecase = ref.read(playbackPermissionUsecaseProvider);
    final permissionResult = await permissionUsecase.check(
      track.albumId,
      track.trackId,
    );

    if (permissionResult.isError) {
      context.showToast(permissionResult.message ?? '재생 권한 오류');
      return;
    }

    final playableTrack = await _fetchPlayableTrack(
      ref,
      dio,
      track.albumId,
      track.trackId,
      context,
    );
    await _playAndSetState(ref, playableTrack);
  }

  Future<void> playFromQueueSubset(
    BuildContext context,
    WidgetRef ref,
    List<Track> fullQueue,
    Track selectedTrack,
  ) async {
    final permissionUsecase = ref.read(playbackPermissionUsecaseProvider);
    final dio = ref.read(dioProvider);
    final allowedTracks = <Track>[];

    for (final track in fullQueue) {
      final result = await permissionUsecase.check(
        track.albumId,
        track.trackId,
      );
      if (!result.isError) {
        allowedTracks.add(track);
      }
    }

    if (allowedTracks.isEmpty) {
      context.showToast('⛔ 재생 가능한 트랙이 없습니다.');
      return;
    }

    final initialIndex = allowedTracks.indexWhere(
      (t) => t.trackId == selectedTrack.trackId,
    );

    if (initialIndex == -1) {
      context.showToast('선택한 트랙은 재생할 수 없습니다.');
      return;
    }

    try {
      final playableTrack = await _fetchPlayableTrack(
        ref,
        dio,
        selectedTrack.albumId,
        selectedTrack.trackId,
        context,
      );
      await _playAndSetState(ref, playableTrack);
    } catch (e) {
      context.showToast(e.toString());
      return;
    }

    _playlistSource.clear();
    for (final track in allowedTracks) {
      _playlistSource.add(AudioSource.uri(Uri.parse(track.trackFileUrl ?? '')));
    }

    await audioPlayer.setAudioSource(
      _playlistSource,
      initialIndex: initialIndex,
    );
  }

  Future<void> playPlaylistFromTrack(
    WidgetRef ref,
    List<Track> playlist,
    Track startTrack,
    BuildContext context,
  ) async {
    final permissionUsecase = ref.read(playbackPermissionUsecaseProvider);
    final dio = ref.read(dioProvider);
    final allowedTracks = <Track>[];

    // 1. 재생 가능한 트랙 필터링
    for (final track in playlist) {
      final result = await permissionUsecase.check(
        track.albumId,
        track.trackId,
      );
      if (!result.isError) {
        allowedTracks.add(track);
      }
    }

    if (allowedTracks.isEmpty) {
      context.showToast('⛔ 재생 가능한 트랙이 없습니다.');
      return;
    }

    final initialIndex = 0;

    // 2. 첫 트랙 정보 로드 및 상태 갱신
    try {
      final track = await _fetchPlayableTrack(
        ref,
        dio,
        allowedTracks.first.albumId,
        allowedTracks.first.trackId,
        context,
      );
      await _playAndSetState(ref, track);

      // 🔥 핵심 추가
      allowedTracks[0] = track;
    } catch (e) {
      context.showToast(e.toString());
      return;
    }

    // 3. 현재 로그인한 사용자 ID 가져오기
    final userId = ref.read(authUserIdProvider);

    // 4. 기존 재생목록 불러오기 (data.Track → domain.Track 변환)
    final existingQueue = (await loadListeningQueue(userId)).cast<data.Track>();
    final existingQueueDomain =
        existingQueue.map(mapDataTrackToDomain).toList();

    // 5. 새 트랙을 최상단에 추가
    final merged = [...allowedTracks, ...existingQueueDomain];
    final finalQueue = merged;

    // 6. Hive에 저장 (domain → data로 변환해서 저장)
    final dataQueue = finalQueue.map((t) => t.toDataModel()).toList();
    await saveListeningQueue(userId, dataQueue);

    // 7. 재생 목록 구성
    _playlistSource.clear();
    for (final t in finalQueue) {
      _playlistSource.add(AudioSource.uri(Uri.parse(t.trackFileUrl ?? '')));
    }

    await audioPlayer.setAudioSource(_playlistSource, initialIndex: 0);
    ref.read(listeningQueueProvider.notifier).loadQueue(); // ← 이걸 추가
  }

  Future<void> _playAndSetState(WidgetRef ref, Track track) async {
    final uniqueId = "track_${track.trackId}";

    // ✅ 1. 상태 먼저 업데이트
    ref
        .read(playbackProvider.notifier)
        .updateTrackInfo(
          trackTitle: track.trackTitle,
          artist: track.artistName,
          coverImageUrl: track.coverUrl ?? '',
          lyrics: track.lyric ?? '',
          currentTrackId: track.trackId,
          albumId: track.albumId,
          trackUrl: track.trackFileUrl ?? '',
          isLiked: false,
          currentQueueItemId: uniqueId,
        );
    ref.read(playbackProvider.notifier).updatePlaybackState(true);

    // ✅ 2. 오디오 재생 시작 (상태 업데이트 후!)
    await _playSingleTrack(ref, track);
  }

  Future<Track> _fetchPlayableTrack(
    WidgetRef ref,
    Dio dio,
    int albumId,
    int trackId,
    BuildContext context,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/albums/$albumId/tracks/$trackId',
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.data == null) {
        final code = response.data['error']?['code'];
        final message = switch (code) {
          'S001' => '🔒 구독권이 없습니다. 구독 후 이용해 주세요.',
          'S002' => '🚫 현재 구독권으로는 재생할 수 없습니다.',
          'S003' => '⚠️ 로그인 후 이용해 주세요.',
          _ => '❌ 알 수 없는 오류가 발생했습니다.',
        };

        context.showToast(message);
        return Future.error(message);
      }

      final data = apiResponse.data!;
      return Track(
        trackId: trackId,
        albumId: albumId,
        trackTitle: data['title'] ?? '',
        artistName: data['artist'] ?? '',
        lyric: data['lyrics'] ?? '',
        trackFileUrl: data['trackFileUrl'] ?? '',
        coverUrl: data['coverImageUrl'] ?? '',
        trackNumber: 0,
        commentCount: 0,
        lyricist: [''],
        composer: [''],
        comments: [],
        createdAt: DateTime.now().toString(),
        trackLikeCount: 0,
        albumTitle: '',
        genreName: '',
      );
    } on DioException catch (e) {
      final code = e.response?.data['error']?['code'];
      final message = switch (code) {
        'S001' => '🔒 구독권이 없습니다. 구독 후 이용해 주세요.',
        'S002' => '🚫 현재 구독권으로는 재생할 수 없습니다.',
        'S003' => '⚠️ 로그인 후 이용해 주세요.',
        _ => '❌ 알 수 없는 오류가 발생했습니다.',
      };

      context.showToast(message);
      return Future.error(message); // 흐름 중단
    }
  }

  Future<void> _playSingleTrack(WidgetRef ref, Track track) async {
    final url = track.trackFileUrl ?? '';
    final source = AudioSource.uri(Uri.parse(url));
    try {
      print('[DEBUG] 🎧 setAudioSource 시도 중... URL: $url');

      // 1. 소스 설정
      final duration = await audioPlayer.setAudioSource(source);
      print('[DEBUG] ✅ AudioSource 세팅 완료, duration: $duration');

      // 2. 재생 시작
      await audioPlayer.play();
      print('[DEBUG] 🔊 오디오 재생 시작됨');

      // ✅ 3. 상태 갱신 (여기서 직접 반영)
      ref.read(playbackProvider.notifier).updatePlaybackState(true);
    } catch (e) {
      print('[ERROR] 오디오 재생 중 오류 발생: $e');
      throw Exception('오디오 재생 중 오류 발생: $e');
    }
  }

  Future<void> resume(WidgetRef ref) async {
    await audioPlayer.play();
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  Future<void> pause(WidgetRef ref) async {
    await audioPlayer.pause();
    ref.read(playbackProvider.notifier).updatePlaybackState(false);
  }

  Future<void> seekTo(Duration position) async {
    await audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    await audioPlayer.seekToNext();
    await audioPlayer.play();
  }

  Future<void> playPrevious() async {
    await audioPlayer.seekToPrevious();
    await audioPlayer.play();
  }

  Future<void> toggleShuffle() async {
    final enabled = audioPlayer.shuffleModeEnabled;
    await audioPlayer.setShuffleModeEnabled(!enabled);
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    await audioPlayer.setLoopMode(loopMode);
  }
}

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
