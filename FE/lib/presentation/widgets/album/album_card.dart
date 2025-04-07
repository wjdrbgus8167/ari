import 'package:ari/core/services/audio_service.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/widgets/common/media_card.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';

class AlbumCard extends ConsumerWidget {
  final Album album;
  const AlbumCard({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.read(audioServiceProvider); // ✅ 인스턴스 가져오기

    return MediaCard(
      imageUrl: album.coverImageUrl,
      title: album.albumTitle,
      subtitle: album.artist,
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.album,
          arguments: {'albumId': album.albumId},
        );
      },
      onPlayPressed: () {
        print('[DEBUG] album.tracks.length = ${album.tracks.length}');
        for (final track in album.tracks) {
          print(
            '[DEBUG] ▶️ trackId=${track.trackId}, title=${track.trackTitle}, fileUrl=${track.trackFileUrl}',
          );
        }

        if (album.tracks.isEmpty) {
          context.showToast('앨범에 재생 가능한 트랙이 없습니다.');
          return;
        }

        audioService.playPlaylistFromTrack(
          ref,
          album.tracks,
          album.tracks.first,
        );
      },
    );
  }
}
