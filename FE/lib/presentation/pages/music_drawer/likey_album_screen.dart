import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/providers/music_drawer/music_drawer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikeyAlbumsScreen extends ConsumerStatefulWidget {
  const LikeyAlbumsScreen({super.key});

  @override
  LikeyAlbumsScreenState createState() => LikeyAlbumsScreenState();
}

class LikeyAlbumsScreenState extends ConsumerState<LikeyAlbumsScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 구독 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likeyAlbumsViewModelProvider.notifier).loadLikeyAlbums();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ref.watch(likeyAlbumsViewModelProvider).isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: Colors.black),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 헤더 섹션
                  HeaderWidget(
                    type: HeaderType.backWithTitle,
                    title: "좋아요 누른 앨범",
                    onBackPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  
                ],
              ),
            ),
    );
  }
}