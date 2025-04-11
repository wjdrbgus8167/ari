import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/album_detail/album_like_button.dart';
import 'package:ari/providers/album/album_detail_providers.dart';
import 'package:flutter/material.dart';
import 'package:ari/presentation/widgets/album_detail/show_rate_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlbumDetailTitle extends ConsumerWidget {
  final int albumId;

  const AlbumDetailTitle({super.key, required this.albumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumState = ref.watch(albumDetailViewModelProvider(albumId));
    final album = albumState.album;

    if (album == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final double parsedRating = double.tryParse(album.rating) ?? 0.0;
    final int fullStars = parsedRating.floor();
    final bool hasHalfStar = (parsedRating - fullStars) >= 0.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      clipBehavior: Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            album.albumTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.myChannel,
                arguments: {'memberId': album.artistId.toString()},
              );
            },
            child: Text(
              album.artist,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AlbumLikeButton(
                    albumId: album.albumId,
                    albumLikedYn: album.albumLikedYn ?? false,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    album.albumLikeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    album.commentCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              /// ⭐ 별점 영역
              GestureDetector(
                onTap: () {
                  showRatingModal(
                    context: context,
                    ref: ref,
                    albumId: album.albumId,
                  );
                },
                child: Row(
                  children: [
                    // ⭐ 총 5개의 별을 보여주되, 가득/반/빈 조합
                    ...List.generate(5, (index) {
                      if (index < fullStars) {
                        return const Icon(
                          Icons.star,
                          size: 20,
                          color: AppColors.mediumPurple,
                        );
                      } else if (index == fullStars && hasHalfStar) {
                        return const Icon(
                          Icons.star_half,
                          size: 20,
                          color: AppColors.mediumPurple,
                        );
                      } else {
                        return const Icon(
                          Icons.star_border,
                          size: 20,
                          color: AppColors.mediumPurple,
                        );
                      }
                    }),
                    const SizedBox(width: 4),
                    Text(
                      parsedRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 0.5,
                      color: Color(0xFF989595),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  album.genre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 0.5,
                      color: Color(0xFF989595),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  album.createdAt.split(' ')[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
