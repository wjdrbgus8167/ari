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

  // 현재 선택된 년월 상태 추가
  int _selectedYear = 2025;
  int _selectedMonth = 4; // 기본값은 4월

  // 일간 구독자 데이터를 차트 데이터로 변환하고 누락된 날짜는 0으로 채우기
  List<ChartData> _convertSubscriberDataToChartData(ArtistDashboardData data) {
    // 1. 기존 데이터 변환
    final Map<int, double> subscriberByDay = {};
    
    // 현재 선택된 년월에 해당하는 데이터만 필터링
    final selectedYearMonthStr = "${_selectedYear.toString().substring(2)}.${_selectedMonth.toString().padLeft(2, '0')}";
    
    // 데이터 형식에 따라 다른 처리
    for (var item in data.dailySubscriberCounts) {
      // 날짜 형식에 따라 일자와 년월 추출 (YYYY-MM-DD 또는 YY.MM.DD)
      int day;
      String yearMonth;
      
      if (item.date.contains('-')) {
        // YYYY-MM-DD 형식 (예: 2025-04-07)
        final parts = item.date.split('-');
        if (parts.length == 3) {
          yearMonth = "${parts[0].substring(2)}.${parts[1]}"; // "25.04" 형식으로 변환
          day = int.tryParse(parts[2]) ?? 0;
        } else {
          continue; // 잘못된 날짜 형식은 건너뜀
        }
      } else {
        // YY.MM.DD 형식 (예: 25.04.07)
        final parts = item.date.split('.');
        if (parts.length == 3) {
          yearMonth = "${parts[0]}.${parts[1]}"; // "25.04" 형식
          day = int.tryParse(parts[2]) ?? 0;
        } else {
          continue; // 잘못된 날짜 형식은 건너뜀
        }
      }
      
      // 현재 선택된 년월에 해당하는 데이터만 사용
      if (yearMonth == selectedYearMonthStr && day > 0) {
        subscriberByDay[day] = item.subscriberCount.toDouble();
      }
    }
    
    // 2. 해당 월의 총 일수 계산
    final daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
    
    // 3. 누락된 날짜를 0으로 채우기 (1 ~ 해당 월의 마지막 일)
    for (int day = 1; day <= daysInMonth; day++) {
      if (!subscriberByDay.containsKey(day)) {
        subscriberByDay[day] = 0.0; // 없는 날짜는 0으로 설정
      }
    }
    
    // 4. 결과를 ChartData 리스트로 변환하고 정렬
    final result = subscriberByDay.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
    
    // 날짜순으로 정렬
    result.sort((a, b) => a.x.compareTo(b.x));
    
    return result;
  }

  // 정산 데이터를 차트 데이터로 변환하고 누락된 날짜는 0으로 채우기
  List<ChartData> _convertSettlementDataToChartData(ArtistDashboardData data) {
    // 1. 기존 데이터 변환
    final Map<int, double> settlementByDay = {};
    
    // 현재 선택된 년월에 해당하는 데이터만 필터링
    final selectedYearMonthStr = "${_selectedYear.toString().substring(2)}.${_selectedMonth.toString().padLeft(2, '0')}";
    
    // 데이터 파싱
    for (var item in data.dailySettlement) {
      // YY.MM.DD 형식 (예: 25.04.07)
      final parts = item.date.split('.');
      if (parts.length == 3) {
        final yearMonth = "${parts[0]}.${parts[1]}";
        final day = int.tryParse(parts[2]) ?? 0;
        
        // 현재 선택된 년월에 해당하는 데이터만 사용
        if (yearMonth == selectedYearMonthStr && day > 0) {
          settlementByDay[day] = item.settlement;
        }
      }
    }
    
    // 2. 해당 월의 총 일수 계산
    final daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
    
    // 3. 누락된 날짜를 0으로 채우기 (1 ~ 해당 월의 마지막 일)
    for (int day = 1; day <= daysInMonth; day++) {
      if (!settlementByDay.containsKey(day)) {
        settlementByDay[day] = 0.0; // 없는 날짜는 0으로 설정
      }
    }
    
    // 4. 결과를 ChartData 리스트로 변환하고 정렬
    final result = settlementByDay.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
    
    // 날짜순으로 정렬
    result.sort((a, b) => a.x.compareTo(b.x));
    
    return result;
  }

  // 해당 년월의 일수 계산 함수
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // 이전 월로 이동
  void _goToPreviousMonth() {
    setState(() {
      if (_selectedMonth > 1) {
        _selectedMonth--;
      } else {
        _selectedMonth = 12;
        _selectedYear--;
      }
    });
  }

  // 다음 월로 이동
  void _goToNextMonth() {
    setState(() {
      if (_selectedMonth < 12) {
        _selectedMonth++;
      } else {
        _selectedMonth = 1;
        _selectedYear++;
      }
    });
  }

  // 월 선택 UI 위젯
  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // 패딩 줄임
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 10, color: Colors.white), // 아이콘 크기도 약간 줄임
            padding: EdgeInsets.zero, // 패딩 제거
            constraints: const BoxConstraints(), // 기본 제약 제거
            visualDensity: VisualDensity.compact, // 더 작은 크기로 표시
            onPressed: _goToPreviousMonth,
          ),
          Text(
            "${_selectedYear}년 ${_selectedMonth}월",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11, // 폰트 크기 줄임
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white), // 아이콘 크기도 약간 줄임
            padding: EdgeInsets.zero, // 패딩 제거
            constraints: const BoxConstraints(), // 기본 제약 제거
            visualDensity: VisualDensity.compact, // 더 작은 크기로 표시
            onPressed: _goToNextMonth,
          ),
        ],
      ),
    );
  }

  // 차트 섹션 UI (월 선택기만 포함)
  Widget _buildChartSection(String title, ChartType chartType, List<ChartData> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목과 월 선택기를 함께 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildMonthSelector(),
            ],
          ),
          const SizedBox(height: 10),
          // 수정된 간소화 차트 위젯 사용
          SimpleChartWidget(
            chartType: chartType,
            data: data,
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // 대시보드 데이터 가져오기
    final dashboardData = ref.watch(artistDashboardProvider);
    final hasWallet = dashboardData.walletAddress != null && dashboardData.walletAddress!.isNotEmpty;
    
    // 앨범/트랙 보유 여부 확인 (실제로는 API 호출 등으로 확인)
    final hasTracks = true; // 앨범이 있으면 트랙이 있다고 가정

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
                                  ),
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
                          // 지갑 위젯
                          const WalletWidget(),
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
                                  }
                                );
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
                    
                    // 기록 섹션
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 16), // 좌우 마진 추가
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
                    const SizedBox(height: 20),
                    if (hasTracks) ...[
                      // 구독자 수 차트
                     
                      // 전체 월의 데이터를 보이도록 변환
                            _buildChartSection(
                              '구독자 수 추이',
                              ChartType.subscribers,
                              _convertSubscriberDataToChartData(dashboardData),
                            ),
                            const SizedBox(height: 10),
                            // 정산금액 차트
                            _buildChartSection(
                              '정산금액 추이',
                              ChartType.revenue,
                              _convertSettlementDataToChartData(dashboardData),
                            ),
                    
                    ],
                  ],
                ),
              ),
              ]
            ),
          ),
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