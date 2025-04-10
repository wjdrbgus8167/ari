import 'package:ari/core/services/audio_service.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/data/models/music_drawer/likey_tracks_model.dart';
import 'package:ari/providers/music_drawer/music_drawer_providers.dart';
import 'package:ari/presentation/widgets/listening_queue/track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 좋아요 누른 트랙 화면 (리펙토링된 버전)
class LikeyTracksScreen extends ConsumerStatefulWidget {
  const LikeyTracksScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LikeyTracksScreen> createState() => _LikeyTracksScreenState();
}

class _LikeyTracksScreenState extends ConsumerState<LikeyTracksScreen> {
  // LikeyTrack 데이터를 Track 엔티티로 변환하는 헬퍼 함수
  Track _convertLikeyToTrack(LikeyTrack likey) {
    return Track(
      trackId: likey.trackId,
      trackTitle: likey.trackTitle,
      artistName: likey.artist,
      coverUrl: likey.coverImageUrl,
      albumId: likey.albumId,
      albumTitle: '',
      genreName: '',
      lyric: '',
      trackNumber: 0,
      commentCount: 0,
      lyricist: [],
      composer: [],
      comments: [],
      createdAt: '',
      trackFileUrl: '',
      trackLikeCount: 0,
    );
  }

  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 좋아요 누른 트랙 데이터를 불러옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likeyTracksViewModelProvider.notifier).loadLikeyTracks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final likeyState = ref.watch(likeyTracksViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("좋아요 누른 트랙"),
      ),
      body:
          likeyState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : likeyState.errorMessage != null
              ? Center(
                child: Text(
                  "Error: ${likeyState.errorMessage}",
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : likeyState.likeyTracks.isEmpty
              ? const Center(
                child: Text(
                  "좋아요 누른 트랙이 없습니다.",
                  style: TextStyle(color: Colors.white),
                ),
              )
              : ListView.builder(
                itemCount: likeyState.likeyTracks.length,
                itemBuilder: (context, index) {
                  final likey = likeyState.likeyTracks[index];
                  // 변환: LikeyTrack -> Track
                  final track = _convertLikeyToTrack(likey);
                  return TrackListTile(
                    key: ValueKey('${likey.trackId}-${likey.trackTitle}'),
                    track: track,
                    // 좋아요 트랙의 경우 선택 기능이 없다면 false로 고정
                    isSelected: false,
                    onToggleSelection: () {
                      // 선택 기능이 필요한 경우 ViewModel의 토글 함수 연결
                    },
                    onTap: () {
                      // 재생 기능 호출. 아래 예시는 단일 트랙 재생 처리.
                      // 필요에 따라 전체 좋아요 목록 재생 등의 로직을 구현할 수 있습니다.
                      ref.read(audioServiceProvider).playFromQueueSubset(
                        context,
                        ref,
                        [track], // 단일 트랙 재생 – 혹은 전체 목록으로 변환하여 전달
                        track,
                      );
                    },
                  );
                },
              ),
    );
  }
}
