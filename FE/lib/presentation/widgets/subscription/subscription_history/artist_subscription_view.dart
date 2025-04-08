// widgets/subscription/artist_subscription_view.dart
import 'package:ari/data/models/subscription/artist_subscription_models.dart';
import 'package:ari/data/models/subscription/regular_subscription_models.dart';
import 'package:ari/presentation/viewmodels/subscription/artist_subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtistSubscriptionView extends ConsumerWidget {
  const ArtistSubscriptionView({Key? key}) : super(key: key);

  final bool _didLoad = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.read(artistSubscriptionViewModelProvider);

    // 데이터 로드 (필요 시)
    if (!_didLoad && state.artists.isEmpty && !state.isLoading) {
      Future.microtask(
        () =>
            ref
                .read(artistSubscriptionViewModelProvider.notifier)
                .loadArtistList(),
      );
    }

    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(state.errorMessage!, style: TextStyle(color: Colors.red)),
      );
    }

    if (state.artists.isEmpty) {
      return Center(
        child: Text('구독한 아티스트가 없습니다.', style: TextStyle(color: Colors.white)),
      );
    }

    final selectedArtist = state.selectedArtist;
    final artistDetail = state.artistDetail;

    if (selectedArtist == null || artistDetail == null) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아티스트 선택 부분 (드롭다운으로 변경)
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: DropdownButton<Artist>(
              value: selectedArtist,
              dropdownColor: const Color(0xFF373737),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: Container(), // 밑줄 제거
              onChanged: (newValue) {
                if (newValue != null) {
                  ref
                      .read(artistSubscriptionViewModelProvider.notifier)
                      .selectArtist(newValue);
                }
              },
              items:
                  state.artists.map<DropdownMenuItem<Artist>>((artist) {
                    return DropdownMenuItem<Artist>(
                      value: artist,
                      child: Text(artist.artistNickname),
                    );
                  }).toList(),
            ),
          ),

          // 아티스트 구독 정보
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: const Color(0xFFDE85FC),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 구독 정보 헤더
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${artistDetail.artistNickname} 구독',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  artistDetail.totalSettlement.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        "https://placehold.co/20x20",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '총 ${artistDetail.totalStreamingCount}회 스트리밍',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 구독 내역 목록
                  _buildSubscriptionDetails(artistDetail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails(ArtistDetail artistDetail) {
    return Column(
      children:
          artistDetail.subscriptions
              .map(
                (subscription) =>
                    _buildSubscriptionDetailItem(artistDetail, subscription),
              )
              .toList(),
    );
  }

  Widget _buildSubscriptionDetailItem(
    ArtistDetail artistDetail,
    ArtistSubscriptionDetail subscription,
  ) {
    return Container(
      width: double.infinity,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage(artistDetail.profileImageUrl ?? ''),
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subscription.startedAt} ~ ${subscription.endedAt} ${subscription.planType == 'M' ? '정기 구독' : '아티스트 구독'}',
                      style: TextStyle(
                        color: const Color(0xFFD9D9D9),
                        fontSize: 8,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '${subscription.settlement}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 5),
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/15x15"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
