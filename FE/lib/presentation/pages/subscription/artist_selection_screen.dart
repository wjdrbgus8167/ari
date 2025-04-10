import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/subscription/artist_selection_viewmodel.dart';
import 'package:ari/presentation/widgets/common/button_large.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/subscription/artist_selection/artist_selection_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 상태 관리를 위해 ConsumerStatefulWidget으로 변경
class ArtistSelectionScreen extends ConsumerStatefulWidget {
  const ArtistSelectionScreen({super.key});

  @override
  ConsumerState<ArtistSelectionScreen> createState() =>
      _ArtistSelectionScreenState();
}

class _ArtistSelectionScreenState extends ConsumerState<ArtistSelectionScreen> {
  // 검색어를 저장할 상태 변수
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final artistSelectionViewModel = ref.watch(artistInfoProvider);

    // 검색어에 따라 필터링된 아티스트 목록
    final filteredArtists =
        artistSelectionViewModel.artistInfos
            .where(
              (artist) =>
                  artist.name.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true, // 키보드가 올라올 때 화면 리사이징
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 섹션 (고정)
            HeaderWidget(
              type: HeaderType.backWithTitle,
              title: "구독하기",
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            
            // 중간 콘텐츠와 하단 버튼을 포함하는 Expanded
            Expanded(
              child: Stack(
                children: [
                  // 스크롤 가능한 콘텐츠
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      width: double.infinity,
                      // 하단 버튼을 위한 여백 추가
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 70, // 하단 버튼을 위한 여백 추가
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 리스트 헤더 (검색 기능 추가)
                          Container(
                            width: double.infinity,
                            height: 40,
                            padding: const EdgeInsets.only(
                              top: 6,
                              left: 5,
                              right: 10,
                              bottom: 6,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Color(0xFF989595),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: '아티스트 검색',
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(bottom: 8),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                  ),
                                ),
                                const Icon(Icons.search, color: Colors.white),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 팔로잉 섹션
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 팔로잉 헤더
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      '팔로잉 목록',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '전체',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${filteredArtists.length}', // 필터링된 개수로 변경
                                          style: const TextStyle(
                                            color: Color(0xFF989595),
                                            fontSize: 16,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),

                                // 팔로잉 리스트 (필터링된 목록 사용)
                                SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children:
                                        filteredArtists.map((artistInfo) {
                                          return ArtistSelectionListItem(
                                            artistInfo: artistInfo,
                                            onToggleSubscription: () {
                                              // 구독 중인 경우: 아무 동작 안 함
                                              if (artistInfo.isSubscribed) {
                                                return;
                                              }
                                              // 구독 중이 아닌 경우: 체크 상태 토글
                                              else {
                                                ref
                                                    .read(
                                                      artistInfoProvider.notifier,
                                                    )
                                                    .toggleCheck(artistInfo.id);
                                              }
                                            },
                                          );
                                        }).toList(),
                                  ),
                                ),

                                // 검색 결과가 없는 경우 메시지 표시
                                if (filteredArtists.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 30,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '검색 결과가 없습니다',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 하단 고정 버튼 (키보드가 올라와도 위에 표시)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black, // 버튼 배경
                      child: ButtonLarge(
                        text: "구독하기",
                        onPressed: () => ref
                            .read(artistInfoProvider.notifier)
                            .navigateToSubscriptionPage(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}