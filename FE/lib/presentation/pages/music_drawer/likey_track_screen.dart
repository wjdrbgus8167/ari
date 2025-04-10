import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/providers/music_drawer/music_drawer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikeyTracksScreen extends ConsumerStatefulWidget {
  const LikeyTracksScreen({super.key});

  @override
  LikeyTracksScreenState createState() => LikeyTracksScreenState();
}

class LikeyTracksScreenState extends ConsumerState<LikeyTracksScreen> {
    @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 구독 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likeyTracksViewModelProvider.notifier).loadLikeyTracks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ref.watch(likeyTracksViewModelProvider).isLoading
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
                    title: "좋아요 누른 트랙",
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