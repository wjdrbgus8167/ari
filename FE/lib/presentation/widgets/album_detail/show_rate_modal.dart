import 'package:ari/providers/album/album_detail_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 반드시 본인 프로젝트에 맞는 ViewModel Provider 경로를 import하세요.
import 'package:ari/presentation/viewmodels/album/album_detail_viewmodel.dart';

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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('평점을 선택하세요', style: TextStyle(color: Colors.white)),
                Slider(
                  value: rating,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: rating.toString(),
                  onChanged: (val) => setState(() => rating = val),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final success = await ref
                        .read(albumDetailViewModelProvider(albumId).notifier)
                        .submitRating(albumId, rating);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? '등록 완료!' : '등록 실패 😢')),
                    );
                    if (success) {
                      await ref
                          .read(albumDetailViewModelProvider(albumId).notifier)
                          .loadAlbumDetail(albumId);
                    }
                  },
                  child: const Text("제출"),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
