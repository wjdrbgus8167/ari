// widgets/subscription/regular_subscription_view.dart
import 'package:ari/data/models/subscription/regular_subscription_models.dart';
import 'package:ari/presentation/viewmodels/subscription/regular_subscription_viewmodel.dart';
import 'package:ari/presentation/widgets/subscription/subscription_history/subscription_chart.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegularSubscriptionView extends ConsumerStatefulWidget {
  const RegularSubscriptionView({Key? key}) : super(key: key);

  @override
  _RegularSubscriptionViewState createState() => _RegularSubscriptionViewState();
}

class _RegularSubscriptionViewState extends ConsumerState<RegularSubscriptionView> {
  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    Future.microtask(() => ref.read(regularSubscriptionViewModelProvider.notifier).loadSubscriptionCycles());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(regularSubscriptionViewModelProvider);

    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }
    
    if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!, style: TextStyle(color: Colors.red)));
    }
    
    // 표시할 아티스트 목록 - 더보기 상태에 따라 전체 또는 최대 3개만 표시
    final displaySettlements = state.displaySettlements;
    final artistAllocations = state.artistAllocations;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 구독 기간 표시 (드롭다운으로 변경)
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: state.cycles.isEmpty 
                ? SizedBox() // 사이클이 없으면 빈 공간 표시
                : DropdownButton<SubscriptionCycle>(
                    value: state.selectedCycle,
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
                        ref.read(regularSubscriptionViewModelProvider.notifier).selectCycle(newValue);
                      }
                    },
                    items: state.cycles.map<DropdownMenuItem<SubscriptionCycle>>((cycle) {
                      return DropdownMenuItem<SubscriptionCycle>(
                        value: cycle,
                        child: Text('${cycle.startedAt} ~ ${cycle.endedAt} 정기 구독'),
                      );
                    }).toList(),
                  ),
          ),
          
          // 구독 정보 컨테이너
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: ShapeDecoration(
              color: Colors.black,
              shape: Border(bottom: BorderSide(width: 1, color: Colors.white)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 구독 금액 정보
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 구독',
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
                            state.subscriptionDetail?.price.toString() ?? '0.0',
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
                                image: NetworkImage("https://placehold.co/20x20"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // 차트
                if (artistAllocations.isNotEmpty)
                  SubscriptionChart(artistAllocations: artistAllocations),
                
                SizedBox(height: 60),
                
                // 아티스트 목록
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: displaySettlements.map((settlement) => _buildArtistItem(settlement)).toList(),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // 더 보기 버튼 - 3개 이상일 때만 표시
                if (state.subscriptionDetail != null && state.subscriptionDetail!.settlements.length > 3)
                  GestureDetector(
                    onTap: () {
                      ref.read(regularSubscriptionViewModelProvider.notifier).toggleShowAllArtists();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF323232),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        state.showAllArtists ? '접기' : '더 보기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // 아티스트별 스트리밍 정보
          ...displaySettlements.map((settlement) => _buildArtistStreamingInfo(settlement)).toList(),
        ],
      ),
    );
  }
  
  Widget _buildArtistItem(ArtistSettlement settlement) {
    // 해당 아티스트의 할당정보 찾기
    final allocation = ref.read(regularSubscriptionViewModelProvider).artistAllocations
        .firstWhere(
          (a) => a.artistNickname == settlement.artistNickname, 
          orElse: () => ArtistAllocation(
            artistNickname: settlement.artistNickname,
            profileImageUrl: settlement.profileImageUrl,
            streamingCount: settlement.streamingCount,
            allocation: 0,
            color: Colors.grey,
          )
        );
        
    return Container(
      margin: EdgeInsets.only(bottom: 10), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: ShapeDecoration(
                  color: allocation.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                settlement.artistNickname,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Text(
            '${allocation.allocation.toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArtistStreamingInfo(ArtistSettlement settlement) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 70,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: NetworkImage(settlement.profileImageUrl),
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
                                settlement.artistNickname,
                                style: TextStyle(
                                  color: const Color(0xFFD9D9D9),
                                  fontSize: 8,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${settlement.streamingCount}회 스트리밍',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            settlement.settlement.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}