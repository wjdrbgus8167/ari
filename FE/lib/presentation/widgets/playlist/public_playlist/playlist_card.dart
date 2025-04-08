import 'package:ari/data/mappers/track_mapper.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/presentation/widgets/common/media_card.dart';
import 'package:ari/core/services/audio_service.dart';
import 'package:ari/domain/entities/track.dart';

class PlaylistCard extends ConsumerWidget {
  final Playlist playlist;
  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.read(audioServiceProvider);

    // PlaylistTrackItem → Track 변환 (track 리스트가 비어있지 않다는 가정)
    final List<Track> domainTracks =
        playlist.tracks
            .map((item) => item.toDataTrack().toDomainTrack())
            .toList();

    return MediaCard(
      imageUrl:
          playlist.coverImageUrl.isNotEmpty
              ? playlist.coverImageUrl
              : 'assets/images/default_playlist_cover.png',
      title: playlist.title,
      onTap: () {
        // 플레이리스트 상세 페이지로 이동
        Navigator.pushNamed(
          context,
          AppRoutes.playlistDetail,
          arguments: {'playlistId': playlist.id},
        );
      },
      onPlayPressed: () {
        print('▶️ 재생버튼 눌림: ${playlist.title}');
        print('🧩 playlist.tracks 원본 길이: ${playlist.tracks.length}');
        final List<Track> domainTracks =
            playlist.tracks
                .map((item) => item.toDataTrack().toDomainTrack())
                .toList();

        print('🎵 변환된 트랙 수: ${domainTracks.length}');

        if (domainTracks.isNotEmpty) {
          audioService.playPlaylistFromTrack(
            ref,
            domainTracks,
            domainTracks.first,
            context,
          );
        }
      },
    );
  }
}
