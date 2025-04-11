import 'package:ari/data/mappers/track_mapper.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/common/media_card.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/core/services/audio_service.dart';
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/presentation/viewmodels/playlist/playlist_viewmodel.dart';
import 'package:ari/domain/entities/track.dart';

class PlaylistCard extends ConsumerWidget {
  final Playlist playlist;
  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.read(audioServiceProvider);

    // 현재 PlaylistViewModel 상태를 구독하여, 상세정보가 있는지 확인
    final playlistState = ref.watch(playlistViewModelProvider);
    Playlist detailedPlaylist;

    // 같은 ID의 플레이리스트라면 상세 조회된 정보를 사용
    if (playlistState.selectedPlaylist != null &&
        playlistState.selectedPlaylist!.id == playlist.id &&
        playlistState.selectedPlaylist!.tracks.isNotEmpty) {
      detailedPlaylist = playlistState.selectedPlaylist!;
    } else {
      // 상세 정보가 없으면, API를 통해 상세 조회
      detailedPlaylist = playlist;
    }

    // 재생 전에 상세 정보가 없는 경우 동적으로 가져오기
    Future<void> _handlePlay() async {
      Playlist finalPlaylist = detailedPlaylist;

      // 만약 트랙 정보가 없다면 상세 조회 API를 호출
      if (finalPlaylist.tracks.isEmpty) {
        try {
          final fetched = await ref
              .read(playlistRepositoryProvider)
              .getPlaylistDetail(finalPlaylist.id);
          // 병합: 필요하다면 기존 플레이리스트 정보와 합쳐서 사용
          finalPlaylist = Playlist(
            id: finalPlaylist.id,
            title: finalPlaylist.title,
            coverImageUrl: finalPlaylist.coverImageUrl,
            isPublic: finalPlaylist.isPublic,
            trackCount: fetched.tracks.length,
            shareCount: finalPlaylist.shareCount,
            tracks: fetched.tracks,
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('상세 정보를 불러오지 못했습니다.')));
          return;
        }
      }

      // 변환
      final List<Track> domainTracks =
          finalPlaylist.tracks
              .map((item) => item.toDataTrack().toDomainTrack())
              .toList();

      print('▶️ 재생버튼 눌림: ${finalPlaylist.title}');
      print('🧩 playlist.tracks 원본 길이: ${playlist.tracks.length}');
      print('🎵 최종 재생할 트랙 수: ${finalPlaylist.tracks.length}');

      if (domainTracks.isNotEmpty) {
        audioService.playPlaylistFromTrack(
          ref,
          domainTracks,
          domainTracks.first,
          context,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('재생할 트랙이 없습니다.')));
      }
    }

    return MediaCard(
      imageUrl:
          playlist.coverImageUrl.isNotEmpty
              ? playlist.coverImageUrl
              : 'assets/images/default_playlist_cover.png',
      title: playlist.title,
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.playlistDetail,
          arguments: {'playlistId': playlist.id},
        );
      },
      onPlayPressed: () {
        _handlePlay();
      },
    );
  }
}
