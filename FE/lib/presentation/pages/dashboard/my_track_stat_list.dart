import 'package:ari/presentation/viewmodels/dashboard/track_stat_list_viewmodel.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/dashboard/track_stat_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 10. 수정된 MyTrackStatListScreen
class MyTrackStatListScreen extends ConsumerWidget {
  const MyTrackStatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackListProvider);
    final notifier = ref.read(trackListProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // 헤더 섹션
                HeaderWidget(
                  type: HeaderType.backWithTitle,
                  title: "나의 트랙목록",
                  onBackPressed: () {
                    Navigator.pop(context);
                  },
                ),

                // 정렬 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SortButton(
                        sortBy: state.sortBy,
                        onPressed: () => notifier.changeSortBy(),
                      ),
                    ],
                  ),
                ),

                // 트랙 목록
                Expanded(
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : state.errorMessage != null
                          ? Center(
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                      : state.tracks.isEmpty
                          ? const Center(
                              child: Text(
                                '트랙이 없습니다.',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.tracks.length,
                              itemBuilder: (context, index) {
                                return TrackStatItem(
                                  trackStat: state.tracks[index],
                                  index: index,
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}