import 'package:ari/core/utils/login_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaCard extends ConsumerWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPressed;

  const MediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  // 정사각형 이미지 + 비율 유지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : const AssetImage(
                                        'assets/images/default_album_cover.png',
                                      )
                                      as ImageProvider,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                  // ⏯ 재생 버튼
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () async {
                        final ok = await checkLoginAndNavigateIfNeeded(
                          context: context,
                          ref: ref,
                        );
                        if (!ok) return;
                        if (onPlayPressed != null) {
                          onPlayPressed!();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
