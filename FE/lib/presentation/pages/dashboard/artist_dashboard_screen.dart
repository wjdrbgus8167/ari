import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/core/constants/contract_constants.dart';
import 'package:ari/data/models/dashboard/dashboard_model.dart';
import 'package:ari/presentation/viewmodels/dashboard/artist_dashboard_viewmodel.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/dashboard/chart_widget.dart';
import 'package:ari/presentation/widgets/dashboard/wallet_info_widget.dart';
import 'package:ari/presentation/widgets/subscription/payment/wallet_widget.dart';
import 'package:ari/providers/subscription/walletServiceProviders.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;
import 'dart:math' as math;

class ArtistDashboardScreen extends ConsumerStatefulWidget {
  const ArtistDashboardScreen({super.key});

  @override
  ConsumerState<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends ConsumerState<ArtistDashboardScreen> {
  bool _showWalletInput = false;
  final TextEditingController _walletController = TextEditingController();
  bool isLoading = false; // 로딩 상태

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    Future.microtask(() => ref.read(artistDashboardProvider.notifier).loadDashboardData());
  }
  
  // Helper method to safely set state when component is mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void dispose() {
    _walletController.dispose();
    super.dispose();
  }

  List<ChartData> _convertSubscriberDataToChartData(ArtistDashboardData data) {
  return data.dailySubscriberCounts.map((item) {
    // 날짜 형식에서 일(day) 추출 (예: "25.04.07" -> 7)
    final day = int.tryParse(item.date.split('.').last) ?? 0;
    return ChartData(day, item.subscriberCount.toDouble());
  }).toList();
}

List<ChartData> _convertSettlementDataToChartData(ArtistDashboardData data) {
  return data.dailySettlement.map((item) {
    final day = int.tryParse(item.date.split('.').last) ?? 0;
    return ChartData(day, item.settlement);
  }).toList();
}
  
  @override
  Widget build(BuildContext context) {
    // 대시보드 데이터 가져오기
    final dashboardData = ref.watch(artistDashboardProvider);
    final hasWallet = dashboardData.walletAddress != null;
    
    // 앨범/트랙 보유 여부 확인 (실제로는 API 호출 등으로 확인)
    final hasTracks = true; // 트랙이 있는지 여부를 확인하는 getter가 있다고 가정

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Colors.black),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 섹션
                HeaderWidget(
                  type: HeaderType.backWithTitle,
                  title: "아티스트 대시보드",
                  onBackPressed: () {
                    Navigator.pop(context);
                  },
                ),

                // 메인 컨텐츠
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16), // 좌우 마진 추가
                  padding: const EdgeInsets.all(16), // 패딩 조정
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 0.50, color: Color(0xFF373737)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 트랙 목록 섹션 (트랙이 있을 때만 표시)
                      if (hasTracks)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 변경된 부분
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    '나의 트랙 목록',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => ref.read(artistDashboardProvider.notifier).navigateToAlbumStatList(context),
                                    child: const Icon(
                                      Icons.keyboard_arrow_right_rounded,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      size: 20,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              // 트랙 목록은 별도 위젯으로 구현 예정
                            ],
                          ),
                        ),
                      
                        // 지갑 주소가 있는 경우와 없는 경우 다른 UI 표시
                        if (hasWallet)
                          WalletInfoWidget(
                            walletAddress: dashboardData.walletAddress ?? '',
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF373737),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  // 결제 지갑 연동 섹션 (금액 자동 설정)
                                    const WalletWidget(),
                                  // 버튼 하나추가 -> 함수 실행하는 버튼
                                    const SizedBox(height: 10),
                                    // 지갑 등록 버튼
                                    GestureDetector(
                                      onTap: isLoading ? null : () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        
                                        try {
                                          // 지갑 서비스 가져오기
                                          final walletService = ref.read(walletServiceProvider);
                                          final userId = ref.read(userIdProvider);
                                          final String subscriptionContractAddress = walletService.getCurrentSubscriptionContractAddress();
                                          
                                          if (userId == null) {
                                            dev.log("[구독] 사용자 ID가 없습니다.");
                                            setState(() {
                                              isLoading = false;
                                            });
                                            return;
                                          }
                                          
                                          await walletService.registerArtist(
                                            contractAddress: subscriptionContractAddress,
                                            artistId: int.parse(userId),
                                            contractAbi: SubscriptionConstants.subscriptionContractAbi,
                                            onComplete: (regTxHash, regSuccess, regErrorMessage) {
                                              dev.log("[구독] 사용자 등록 완료: 성공=$regSuccess, 해시=$regTxHash, 오류=$regErrorMessage");
                                              
                                              if (!mounted) return;
                                              
                                              if (regSuccess) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              }
                                          });
                                        } catch (e) {
                                          dev.log("[구독] 사용자 등록 중 오류 발생: ${e.toString()}");
                                          if (mounted) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isLoading ? Colors.grey : const Color(0xFF6C63FF),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              '지갑 등록하기',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: 'Pretendard',
                                                fontWeight: FontWeight.w700,
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
                    
                    // 기록 섹션
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // 좌우 마진 추가
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '기록',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (hasTracks) 
                            // 트랙이 있는 경우 상세 통계 표시
                            _buildDetailedStats(dashboardData)
                          else
                            // 트랙이 없는 경우 간단한 통계 표시
                            _buildSimpleStats(dashboardData),
                        ],
                      ),
                    ),
                    
                    // 차트 섹션 (트랙이 있을 때만 표시)
                    if (hasTracks) ...[
                      // 구독자 수 차트
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 마진 추가
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '구독자 수 추이',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 4월 전체 데이터를 표시하기 위해 _generateFullMonthData 사용
                            ChartWidget(
                              chartType: ChartType.subscribers,
                              data:  _convertSubscriberDataToChartData(dashboardData),
                            ),
                          ],
                        ),
                      ),
                      
                      // 스트리밍 횟수 차트
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 마진 추가
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '스트리밍 횟수 추이',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ChartWidget(
                              chartType: ChartType.streams,
                              data:  _convertSettlementDataToChartData(dashboardData),
                            ),
                          ],
                        ),
                      ),
                      
                      // 정산금액 차트
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 마진 추가
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '정산금액 추이',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ChartWidget(
                              chartType: ChartType.revenue,
                              data:  _convertSettlementDataToChartData(dashboardData),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
    }
    
    // 4월 전체 구독자 데이터 생성 (1일~30일)
    List<ChartData> _generateFullMonthSubscriberData(ArtistDashboardData data) {
      // 구독자 수 증가 추세 생성 (예측 데이터)
      final Map<int, int> subscriberByDay = {};
      
      // 1. 먼저 API에서 가져온 실제 데이터 채우기
      for (var item in data.dailySubscriberCounts) {
        // 날짜에서 일(day) 추출 (예: "25.04.07" -> 7)
        final parts = item.date.split('.');
        if (parts.length == 3) {
          final day = int.tryParse(parts[2]) ?? 0;
          if (day > 0) {
            subscriberByDay[day] = item.subscriberCount;
          }
        }
      }
      
      // 2. 기존 데이터에서 마지막 일자와 첫 일자 찾기
      final existingDays = subscriberByDay.keys.toList()..sort();
      int firstDay = existingDays.isNotEmpty ? existingDays.first : 1;
      int lastDay = existingDays.isNotEmpty ? existingDays.last : 8;
      
      // 첫 일자의 구독자 수
      final firstDayCount = subscriberByDay[firstDay] ?? 600;
      
      // 마지막 일자의 구독자 수
      final lastDayCount = subscriberByDay[lastDay] ?? 650;
      
      // 3. 나머지 일자(9일-30일) 데이터 채우기 - 증가 추세로 예측
      final remainingDays = 30 - lastDay;
      final averageGrowth = remainingDays > 0 ? (lastDayCount - firstDayCount) / (lastDay - firstDay) : 0;
      
      // 9일부터 30일까지 데이터 생성
      final random = math.Random(42); // 시드값 고정해서 일관된 랜덤 생성
      for (int day = lastDay + 1; day <= 30; day++) {
        // 기본 증가 추세에 약간의 랜덤성 추가
        final trend = averageGrowth * (day - lastDay);
        final randomVariation = (random.nextDouble() * 10) - 5; // -5 ~ +5 사이 랜덤값
        
        // 새 구독자 수 = 마지막 일자 + 증가 추세 + 랜덤 변동
        final newCount = (lastDayCount + trend + randomVariation).round();
        subscriberByDay[day] = newCount;
      }
      
      // 4. 첫 일자 이전(1일-firstDay-1)의 데이터 생성 - 필요한 경우
      if (firstDay > 1) {
        for (int day = 1; day < firstDay; day++) {
          // 첫 일자로 가면서 감소하는 추세
          final daysBeforeFirst = firstDay - day;
          final trend = -averageGrowth * daysBeforeFirst;
          final randomVariation = (random.nextDouble() * 8) - 4; // -4 ~ +4 사이 랜덤값
          
          // 새 구독자 수 = 첫 일자 + 감소 추세 + 랜덤 변동
          final newCount = (firstDayCount + trend + randomVariation).round();
          subscriberByDay[day] = math.max(580, newCount); // 최소값 설정
        }
      }
      
      // 5. 결과를 ChartData 리스트로 변환
      final result = <ChartData>[];
      for (int day = 1; day <= 30; day++) {
        final count = subscriberByDay[day] ?? 0;
        result.add(ChartData(day, count.toDouble()));
      }
      
      return result;
    }
    
    // 4월 전체 스트리밍 데이터 생성 (1일~30일)
    List<ChartData> _generateFullMonthStreamingData(ArtistDashboardData data) {
      // 구독자 데이터를 기반으로 스트리밍 데이터 생성
      final subscriberData = _generateFullMonthSubscriberData(data);
      final random = math.Random(12345); // 시드값 고정
      
      return subscriberData.map((item) {
        // 구독자 수의 약 20~25배를 스트리밍 수로 설정
        final multiplier = 20.0 + random.nextDouble() * 5.0;
        // 주말(6, 7, 13, 14, 20, 21, 27, 28)에는 더 높은 스트리밍 (1.2배)
        final isWeekend = item.x % 7 == 6 || item.x % 7 == 0;
        final weekendMultiplier = isWeekend ? 1.2 : 1.0;
        // 변동성 추가
        final variation = (random.nextDouble() * 2 - 1) * 50; // -50 ~ +50
        
        final streams = item.y * multiplier * weekendMultiplier + variation;
        return ChartData(item.x, streams);
      }).toList();
    }
    
    // 4월 전체 정산 데이터 생성 (1일~30일)
    List<ChartData> _generateFullMonthSettlementData(ArtistDashboardData data) {
      // 1. 기존 정산 데이터 맵으로 변환
      final Map<int, double> settlementByDay = {};
      
      // 기존 API 데이터 채우기
      for (var item in data.dailySettlement) {
        final parts = item.date.split('.');
        if (parts.length == 3) {
          final day = int.tryParse(parts[2]) ?? 0;
          if (day > 0) {
            settlementByDay[day] = item.settlement;
          }
        }
      }
      
      // 2. 데이터가 있는 일자 범위 확인
      final existingDays = settlementByDay.keys.toList()..sort();
      int firstDay = existingDays.isNotEmpty ? existingDays.first : 1;
      int lastDay = existingDays.isNotEmpty ? existingDays.last : 8;
      
      // 첫 일자와 마지막 일자의 정산액
      final firstDayAmount = settlementByDay[firstDay] ?? 15.0;
      final lastDayAmount = settlementByDay[lastDay] ?? 20.0;
      
      // 3. 추세 계산
      final averageGrowth = (lastDayAmount - firstDayAmount) / (lastDay - firstDay);
      
      // 4. 나머지 일자 채우기
      final random = math.Random(54321); // 시드값 고정
      
      // 9일부터 30일까지 데이터 생성
      for (int day = lastDay + 1; day <= 30; day++) {
        // 기본 증가 추세에 약간의 랜덤성 추가
        final trend = averageGrowth * (day - lastDay);
        final randomVariation = (random.nextDouble() * 2) - 1; // -1 ~ +1 사이 랜덤값
        
        // 주말에는 수익이 약간 더 높음
        final isWeekend = day % 7 == 6 || day % 7 == 0;
        final weekendBonus = isWeekend ? 2.0 : 0.0;
        
        // 새 정산액 = 마지막 일자 + 증가 추세 + 랜덤 변동 + 주말 보너스
        final newAmount = lastDayAmount + trend + randomVariation + weekendBonus;
        settlementByDay[day] = double.parse(newAmount.toStringAsFixed(1)); // 소수점 첫째 자리까지
      }
      
      // 1일부터 첫 데이터 이전까지 채우기 (필요한 경우)
      if (firstDay > 1) {
        for (int day = 1; day < firstDay; day++) {
          final daysBeforeFirst = firstDay - day;
          final trend = -averageGrowth * daysBeforeFirst;
          final randomVariation = (random.nextDouble() * 1.5) - 0.75;
          
          final isWeekend = day % 7 == 6 || day % 7 == 0;
          final weekendBonus = isWeekend ? 1.5 : 0.0;
          
          final newAmount = firstDayAmount + trend + randomVariation + weekendBonus;
          settlementByDay[day] = double.parse(math.max(10.0, newAmount).toStringAsFixed(1));
        }
      }
      
      // 5. 결과를 ChartData 리스트로 변환
      final result = <ChartData>[];
      for (int day = 1; day <= 30; day++) {
        final amount = settlementByDay[day] ?? 0.0;
        result.add(ChartData(day, amount));
      }
      
      return result;
    }
    
    // 트랙이 있는 경우 상세 통계 위젯
    Widget _buildDetailedStats(ArtistDashboardData data) {
      return Container(
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF373737),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 첫 번째 행: 구독자 수와 총 스트리밍 횟수
            _buildStatsRow([
              _buildStatItem(
                label: '구독자 수',
                value: data.subscriberCount.toString(),
                // 별도의 증감치가 필요하면 추가
              ),
              _buildStatItem(
                label: '총 스트리밍 횟수',
                value: data.totalStreamingCount.toString(),
              ),
            ]),
            
            const SizedBox(height: 15),
            
            // 두 번째 행: 오늘 스트리밍, 오늘 신규 구독자, 오늘 정산액
            _buildStatsRow([
              _buildStatItem(
                label: '오늘 스트리밍',
                value: data.todayStreamingCount.toString(),
                growth: data.streamingDiff,
              ),
              _buildStatItem(
                label: '오늘 신규 구독자',
                value: data.todayNewSubscriberCount.toString(),
                growth: data.newSubscriberDiff,
              ),
              _buildStatItem(
                label: '오늘 정산액',
                value: data.todaySettlement.toStringAsFixed(1),
                growth: data.settlementDiff.toInt(),
                isRevenue: true,
              ),
            ]),
          ],
        ),
      );
    }
    
    // 트랙이 없는 경우 간단한 통계 위젯
    Widget _buildSimpleStats(ArtistDashboardData data) {
      return Container(
        padding: const EdgeInsets.all(10),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF373737),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 첫 번째 행: 구독자 수와 총 스트리밍 횟수
            Container(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '구독자 수',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.subscriberCount > 0 
                              ? data.subscriberCount.toString() 
                              : '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '총 스트리밍 횟수',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.totalStreamingCount > 0 
                              ? data.totalStreamingCount.toString() 
                              : '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            // 두 번째 행: 오늘 스트리밍, 오늘 신규 구독자 수, 오늘 정산액
            Container(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '오늘 스트리밍',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.todayStreamingCount > 0 
                              ? data.todayStreamingCount.toString() 
                              : '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '오늘 신규 구독자',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.todayNewSubscriberCount > 0 
                              ? data.todayNewSubscriberCount.toString() 
                              : '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '오늘 정산액',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.todaySettlement > 0 
                              ? data.todaySettlement.toStringAsFixed(1) 
                              : '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // 통계 항목 행 위젯
    Widget _buildStatsRow(List<Widget> items) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((item) => Expanded(child: item)).toList(),
      );
    }
    
    // 개별 통계 항목 위젯
    Widget _buildStatItem({
      required String label, 
      required String value, 
      int? growth, 
      bool isRevenue = false
    }) {
      // 증감률 표시 텍스트
      final growthText = growth == null ? '' : 
        (growth > 0 ? ' (+$growth)' : ' ($growth)');
      
      // 증감률 색상
      final growthColor = growth == null ? Colors.white : 
        (growth > 0 ? Colors.green : (growth < 0 ? Colors.red : Colors.white));
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: isRevenue ? '\$' : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: growthText,
                    style: TextStyle(
                      color: growthColor,
                      fontSize: 11,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
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