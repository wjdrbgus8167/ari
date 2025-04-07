import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/core/constants/contract_constants.dart';
import 'package:ari/presentation/viewmodels/dashboard/artist_dashboard_viewmodel.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/dashboard/chart_widget.dart';
import 'package:ari/presentation/widgets/dashboard/stats_card_widget.dart';
import 'package:ari/presentation/widgets/dashboard/wallet_info_widget.dart';
import 'package:ari/presentation/widgets/subscription/payment/wallet_widget.dart';
import 'package:ari/providers/subscription/walletServiceProviders.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;

class ArtistDashboardScreen extends ConsumerStatefulWidget {
  const ArtistDashboardScreen({super.key});

  @override
  ConsumerState<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends ConsumerState<ArtistDashboardScreen> {
  bool _showWalletInput = false;
  final TextEditingController _walletController = TextEditingController();
  bool isLoading = false; // Added for loading state
  
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

    
    
    // 지갑 서비스 가져오기
    // 지갑 연결 상태 확인 - StateNotifier에서 가져옴
    final dashboardData = ref.watch(artistDashboardProvider);
    final hasWallet = dashboardData.walletAddress != null;

    
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
                  padding: const EdgeInsets.all(20),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 0.50),
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
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '나의 트랙 목록',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => ref.watch(artistDashboardProvider.notifier).navigateToAlbumStatList(context),
                                    child: Icon(
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
                            padding: const EdgeInsets.all(20),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF373737),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  // 결제 지갑 연동 섹션 (금액 자동 설정)
                                    WalletWidget(),
                                  // 버튼 하나추가 -> 함수 실행하는 버튼
                                    const SizedBox(height: 10),
                                    // 지갑 등록 버튼
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
                        margin: const EdgeInsets.only(bottom: 20),
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
                              StatsCardWidget(
                                subscriberCount: dashboardData.subscriberCount,
                                totalStreamCount: dashboardData.totalStreamCount,
                                monthlyStreamCount: dashboardData.monthlyStreamCount,
                                monthlyStreamGrowth: dashboardData.monthlyStreamGrowth,
                                monthlyNewSubscribers: dashboardData.monthlyNewSubscribers,
                                monthlySubscriberGrowth: dashboardData.monthlySubscriberGrowth,
                                monthlyRevenue: dashboardData.monthlyRevenue,
                                monthlyRevenueGrowth: dashboardData.monthlyRevenueGrowth,
                              )
                            else
                              // 트랙이 없는 경우 간단한 통계 표시
                              Container(
                                width: double.infinity,
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
                                                    dashboardData.subscriberCount > 0 
                                                      ? dashboardData.subscriberCount.toString() 
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
                                                    dashboardData.totalStreamCount > 0 
                                                      ? dashboardData.totalStreamCount.toString() 
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
                                    // 두 번째 행: 금월 스트리밍, 금월 신규 구독자 수, 금월 정산액
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
                                                    '금월 스트리밍',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    dashboardData.monthlyStreamCount > 0 
                                                      ? dashboardData.monthlyStreamCount.toString() 
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
                                                    '금월 신규 구독자 수',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    dashboardData.monthlyNewSubscribers > 0 
                                                      ? dashboardData.monthlyNewSubscribers.toString() 
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
                                                    '금월 정산액',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    dashboardData.monthlyRevenue > 0 
                                                      ? dashboardData.monthlyRevenue.toStringAsFixed(2) 
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
                              ),
                          ],
                        ),
                      ),
                      
                      // 차트 섹션 (트랙이 있을 때만 표시)
                      if (hasTracks) ...[
                        // 월별 구독자 수 차트
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
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
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: ChartWidget(
                                  chartType: ChartType.subscribers,
                                  data: dashboardData.dailySubscribersData,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 월별 스트리밍 횟수 차트
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '스트리밍 횟수 추이',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: ChartWidget(
                                  chartType: ChartType.streams,
                                  data: dashboardData.dailyStreamsData,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 월별 정산금액 차트
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '정산금액 추이',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: ChartWidget(
                                  chartType: ChartType.revenue,
                                  data: dashboardData.dailyRevenueData,
                          ),
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
}