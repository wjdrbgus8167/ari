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

  // 현재 재생 중인 트랙 리스트와 전역 context/ref 저장용
  late List<Track> _currentTrackList;
  BuildContext? _globalContext;
  WidgetRef? _globalRef;

  // 오디오 진행 상태 스트림 (진행도, 전체 길이 등)
  Stream<Duration> get onPositionChanged => audioPlayer.positionStream;
  Stream<Duration?> get onDurationChanged => audioPlayer.durationStream;

  AudioService() {
    _initializePlayer();
  }

  // 🔁 트랙이 끝났을 때 다음 곡 재생 & 집계 API 호출
  void _initializePlayer() {
    audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        final nextIndex = audioPlayer.nextIndex;

        if (nextIndex != null &&
            nextIndex >= 0 &&
            nextIndex < _playlistSource.length) {
          final nextTrack = _currentTrackList[nextIndex];

          try {
            final playable = await _fetchPlayableTrack(
              _globalRef!,
              _globalRef!.read(dioProvider),
              nextTrack.albumId,
              nextTrack.trackId,
              _globalContext!,
            );

            // ✅ 재생 상태를 갱신 + 실제 재생 수행
            await _playAndSetState(_globalRef!, playable);

            // ✅ 오디오 재생 위치를 다음 곡으로 이동
            await audioPlayer.seek(Duration.zero, index: nextIndex);
            await audioPlayer.play();
          } catch (e) {
            _globalContext?.showToast('다음 곡 재생 실패: $e');
          }
        }
      }
    });
  }

  // 📀 전체 트랙 리스트 재생
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
      if (!result.isError) allowedTracks.add(track);
    }

    if (allowedTracks.isEmpty) {
      context.showToast('⛔ 재생 가능한 트랙이 없습니다.');
      return;
    }

    // 🔗 전역 context/ref 저장 (다음 곡 재생 시 사용)
    _globalRef = ref;
    _globalContext = context;
    _currentTrackList = allowedTracks;

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

  // ▶ 단일 트랙 재생 (재생 권한 포함)
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

  // 🧩 특정 큐에서 특정 곡부터 재생
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
      if (!result.isError) allowedTracks.add(track);
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

    _globalRef = ref;
    _globalContext = context;
    _currentTrackList = allowedTracks;

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

  // 📚 플레이리스트에서 특정 트랙부터 전체 재생
  Future<void> playPlaylistFromTrack(
    WidgetRef ref,
    List<Track> playlist,
    Track startTrack,
    BuildContext context,
  ) async {
    final permissionUsecase = ref.read(playbackPermissionUsecaseProvider);
    final dio = ref.read(dioProvider);
    final allowedTracks = <Track>[];

    for (final track in playlist) {
      final result = await permissionUsecase.check(
        track.albumId,
        track.trackId,
      );
      if (!result.isError) allowedTracks.add(track);
    }

    if (allowedTracks.isEmpty) {
      context.showToast('⛔ 재생 가능한 트랙이 없습니다.');
      return;
    }

    _globalRef = ref;
    _globalContext = context;
    _currentTrackList = allowedTracks;

    try {
      final track = await _fetchPlayableTrack(
        ref,
        dio,
        allowedTracks.first.albumId,
        allowedTracks.first.trackId,
        context,
      );
      await _playAndSetState(ref, track);
      allowedTracks[0] = track;
    } catch (e) {
      context.showToast(e.toString());
      return;
    }

    // Hive 저장 및 상태 동기화
    final userId = ref.read(authUserIdProvider);
    final existingQueue = (await loadListeningQueue(userId)).cast<data.Track>();
    final existingQueueDomain =
        existingQueue.map(mapDataTrackToDomain).toList();
    final finalQueue = [...allowedTracks, ...existingQueueDomain];
    final dataQueue = finalQueue.map((t) => t.toDataModel()).toList();
    await saveListeningQueue(userId, dataQueue);

    _playlistSource.clear();
    for (final t in finalQueue) {
      _playlistSource.add(AudioSource.uri(Uri.parse(t.trackFileUrl ?? '')));
    }
    await audioPlayer.setAudioSource(_playlistSource, initialIndex: 0);
    if (_globalContext?.mounted ?? false) {
      _globalRef!.read(listeningQueueProvider(userId).notifier).loadQueue();
    }
  }

  // 🎯 상태 업데이트 + 오디오 재생 처리
  Future<void> _playAndSetState(WidgetRef ref, Track track) async {
    final uniqueId = "track_\${track.trackId}";

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

    await _playSingleTrack(ref, track);
  }

  // 📡 서버에서 스트리밍 가능한 트랙 정보 가져오기 (집계 포함)
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
      return Future.error(message);
    }
  }

  // 🔊 실제 오디오 재생
  Future<void> _playSingleTrack(WidgetRef ref, Track track) async {
    final url = track.trackFileUrl ?? '';
    final source = AudioSource.uri(Uri.parse(url));
    try {
      await audioPlayer.setAudioSource(source);
      await audioPlayer.play();
      ref.read(playbackProvider.notifier).updatePlaybackState(true);
    } catch (e) {
      throw Exception('오디오 재생 중 오류 발생: $e');
    }
  }

  // ▶ 재생/일시정지/탐색/반복 등 기본 컨트롤러
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

  // 🎯 외부에서 직접 트랙 재생을 위한 엔트리
  Future<void> playTrackDirectly(WidgetRef ref, Track track) async {
    await _playAndSetState(ref, track);
  }
}

// 📡 전역 Provider 등록
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
