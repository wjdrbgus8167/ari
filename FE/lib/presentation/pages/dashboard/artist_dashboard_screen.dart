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
  ConsumerState<ArtistDashboardScreen> createState() =>
      _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends ConsumerState<ArtistDashboardScreen> {
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

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: ref.read(artistDashboardProvider.notifier).hasWallet(),
          builder: (context, hasWalletSnapshot) {
            // 로딩 중일 때
            if (hasWalletSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C63FF),
                ),
              );
            }
            // 지갑이 없는 경우 - WalletWidget만 표시
            if (hasWalletSnapshot.data == false) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    HeaderWidget(
                      type: HeaderType.backWithTitle,
                      title: "아티스트 대시보드",
                      onBackPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 20),
                    const WalletWidget(), // 지갑 설정 위젯
                    const SizedBox(height: 10),
                    // 지갑 등록 버튼 (기존 코드 유지)
                    GestureDetector(
                      onTap: isLoading ? null : () async {
                        setState(() {
                          isLoading = true;
                        });
                        
                        try {
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
                            onComplete: (regTxHash, regSuccess, regErrorMessage) async {
                              dev.log("[구독] 사용자 등록 완료: 성공=$regSuccess, 해시=$regTxHash, 오류=$regErrorMessage");
                              
                              if (!mounted) return;
                              
                              if (regSuccess) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          );
                          walletService.initialize(context);
                        await ref.read(artistDashboardProvider.notifier).hasWallet();
                        await ref.read(artistDashboardProvider.notifier).loadDashboardData();
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // 지갑이 있는 경우, 대시보드 데이터 로드 상태 확인
            final dashboardProvider = ref.watch(artistDashboardProvider);
            final isLoadingData = ref.watch(artistDashboardProvider.notifier).isLoadingData;
            
            // 데이터 로딩 중인 경우 로딩 화면 표시
            if (isLoadingData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeaderWidget(
                    type: HeaderType.backWithTitle,
                    title: "아티스트 대시보드",
                    onBackPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF6C63FF),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '투명한 데이터 로드 중...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // 데이터 로드 완료되면 대시보드 표시
            final hasTracks = dashboardProvider.albums;
            
            return SingleChildScrollView(
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
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
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
                          if (hasTracks.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // 트랙 목록은 별도 위젯으로 구현 예정
                                ],
                              ),
                            ),
                          
                          // 지갑 정보 표시
                          WalletInfoWidget(
                            walletAddress: dashboardProvider.walletAddress ?? '',
                          ),

                          // 기록 섹션
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 16),
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
                                if (hasTracks.isNotEmpty) 
                                  // 트랙이 있는 경우 상세 통계 표시
                                  _buildDetailedStats(dashboardProvider)
                                else
                                  // 트랙이 없는 경우 간단한 통계 표시
                                  _buildSimpleStats(dashboardProvider),
                              ],
                            ),
                          ),
                      
                          // 차트 섹션 (트랙이 있을 때만 표시)
                          const SizedBox(height: 20),
                          if (hasTracks.isNotEmpty) ...[
                            ChartSectionWidget(
                              title: '시간별 구독자 수',
                              chartType: ChartType.subscribers,
                              dashboardData: dashboardProvider,
                            ),
                            const SizedBox(height: 10),
                            ChartSectionWidget(
                              title: '시간별 정산금액',
                              chartType: ChartType.revenue,
                              dashboardData: dashboardProvider,
                            ),
                          ],
                          // 차트 섹션 (트랙이 없을 때는 표시하지 않음)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
    
    // 트랙이 있는 경우 상세 통계 위젯
    Widget _buildDetailedStats(ArtistDashboardData data) {
      return Container(
        padding: const EdgeInsets.all(10),
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
                label: '당일 스트리밍',
                value: data.todayStreamingCount.toString(),
                growth: data.streamingDiff,
              ),
              _buildStatItem(
                label: '당일 신규 구독',
                value: data.todayNewSubscriberCount.toString(),
                growth: data.newSubscriberDiff,
              ),
              _buildStatItem(
                label: '당일 정산액',
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
                              fontSize: 13,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
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
                              fontSize: 13,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
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
                            '당일 스트리밍',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
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
                            '당일 신규 구독',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
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
                            '당일 정산액',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
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
                fontSize: 13,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: isRevenue ? '' : '',
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

class ChartDateState {
  int year;
  int month;
  int day;

  ChartDateState({
    required this.year,
    required this.month,
    required this.day,
  });

  // 이전 날짜로 이동
  void goToPrevious() {
    final currentDate = DateTime(year, month, day);
    final previousDate = currentDate.subtract(const Duration(days: 1));
    
    year = previousDate.year;
    month = previousDate.month;
    day = previousDate.day;
  }

  // 다음 날짜로 이동
  void goToNext() {
    final currentDate = DateTime(year, month, day);
    final nextDate = currentDate.add(const Duration(days: 1));
    
    year = nextDate.year;
    month = nextDate.month;
    day = nextDate.day;
  }

  // 날짜 문자열 반환
  String get dateString => "$year.$month.$day";
}

// 독립적인 차트 섹션 위젯
class ChartSectionWidget extends StatefulWidget {
  final String title;
  final ChartType chartType;
  final ArtistDashboardData dashboardData;
  
  const ChartSectionWidget({
    Key? key,
    required this.title,
    required this.chartType,
    required this.dashboardData,
  }) : super(key: key);

  @override
  State<ChartSectionWidget> createState() => _ChartSectionWidgetState();
}

class _ChartSectionWidgetState extends State<ChartSectionWidget> {
  // 이 차트 섹션만의 독립적인 날짜 상태
  late ChartDateState _dateState;

  @override
  void initState() {
    super.initState();
    // 현재 날짜로 초기화
    final now = DateTime.now();
    _dateState = ChartDateState(
      year: now.year,
      month: now.month,
      day: now.day,
    );
  }

  // 시간별 구독자 데이터를 차트 데이터로 변환
  List<ChartData> _convertHourlySubscriberData() {
    final Map<int, double> subscriberByHour = {};
    
    // 선택된 날짜 문자열 생성 (형식: "YY.MM.DD")
    final selectedDateStr = "${_dateState.year.toString().substring(2)}.${_dateState.month.toString().padLeft(2, '0')}.${_dateState.day.toString().padLeft(2, '0')}";
    
    // 데이터 파싱
    for (var item in widget.dashboardData.hourlySubscriberCounts) {
      // 형식은 "YY.MM.DD HH" (예: "25.04.10 14")
      final parts = item.hour.split(' ');
      if (parts.length == 2) {
        final date = parts[0];
        final hour = int.tryParse(parts[1]) ?? 0;
        
        // 선택된 날짜의 데이터만 사용
        if (date == selectedDateStr && hour >= 0 && hour <= 23) {
          subscriberByHour[hour] = item.subscriberCount.toDouble();
        }
      }
    }
    
    // 누락된 시간(0-23)에 0 값 채우기
    for (int hour = 0; hour <= 23; hour++) {
      if (!subscriberByHour.containsKey(hour)) {
        subscriberByHour[hour] = 0.0;
      }
    }
    
    // ChartData 리스트로 변환 및 정렬
    final result = subscriberByHour.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
    
    // 시간순 정렬
    result.sort((a, b) => a.x.compareTo(b.x));
    
    return result;
  }

  // 시간별 정산 데이터를 차트 데이터로 변환
  List<ChartData> _convertHourlySettlementData() {
    final Map<int, double> settlementByHour = {};
    
    // 선택된 날짜 문자열 생성 (형식: "YY.MM.DD")
    final selectedDateStr = "${_dateState.year.toString().substring(2)}.${_dateState.month.toString().padLeft(2, '0')}.${_dateState.day.toString().padLeft(2, '0')}";
    
    // 데이터 파싱
    for (var item in widget.dashboardData.hourlySettlement) {
      // 형식은 "YY.MM.DD HH" (예: "25.04.10 14")
      final parts = item.hour.split(' ');
      if (parts.length == 2) {
        final date = parts[0];
        final hour = int.tryParse(parts[1]) ?? 0;
        
        // 선택된 날짜의 데이터만 사용
        if (date == selectedDateStr && hour >= 0 && hour <= 23) {
          settlementByHour[hour] = item.settlement;
        }
      }
    }
    
    // 누락된 시간(0-23)에 0 값 채우기
    for (int hour = 0; hour <= 23; hour++) {
      if (!settlementByHour.containsKey(hour)) {
        settlementByHour[hour] = 0.0;
      }
    }
    
    // ChartData 리스트로 변환 및 정렬
    final result = settlementByHour.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
    
    // 시간순 정렬
    result.sort((a, b) => a.x.compareTo(b.x));
    
    return result;
  }

  // 날짜 선택기 UI 위젯
  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 10, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              setState(() {
                _dateState.goToPrevious();
              });
            },
          ),
          Text(
            _dateState.dateString,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              setState(() {
                _dateState.goToNext();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 차트 타입에 따라 데이터 변환 함수 선택
    List<ChartData> chartData;
    if (widget.chartType == ChartType.subscribers) {
      chartData = _convertHourlySubscriberData();
    } else {
      chartData = _convertHourlySettlementData();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목과 날짜 선택기 함께 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildDateSelector(),
            ],
          ),
          const SizedBox(height: 10),
          // 차트 위젯
          SimpleChartWidget(
            chartType: widget.chartType,
            data: chartData,
            isHourlyChart: true,
          ),
        ],
      ),
    );
  }
}