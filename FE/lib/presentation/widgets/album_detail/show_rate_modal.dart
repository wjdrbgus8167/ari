import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/providers/album/album_detail_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

Future<void> showRatingModal({
  required BuildContext context,
  required WidgetRef ref,
  required int albumId,
}) async {
  double rating = 0;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '평점을 선택하세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                RatingBar(
                  initialRating: rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  glow: false,
                  itemSize: 36,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  ratingWidget: RatingWidget(
                    full: const Icon(Icons.star, color: Colors.purpleAccent),
                    half: const Icon(
                      Icons.star_half,
                      color: Colors.purpleAccent,
                    ),
                    empty: const Icon(Icons.star_border, color: Colors.grey),
                  ),
                  onRatingUpdate: (value) {
                    setState(() {
                      rating = double.parse(value.toStringAsFixed(1));
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mediumPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    final viewModel = ref.read(
                      albumDetailViewModelProvider(albumId).notifier,
                    );

                    final success = await viewModel.submitRating(
                      albumId,
                      rating,
                    );

                    if (success) {
                      // ✅ 등록 성공 시 상태 최신화
                      await viewModel.loadAlbumDetail(albumId);
                      Navigator.pop(context); // 닫기
                    } else {
                      // 등록 실패 시 안내
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('평점 등록에 실패했습니다.')),
                      );
                    }
                  },
                  child: const Text("제출하기"),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    },
  );
}
