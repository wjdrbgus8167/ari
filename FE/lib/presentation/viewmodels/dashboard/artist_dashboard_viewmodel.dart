import 'dart:math';

import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/dashboard/chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 아티스트 대시보드 데이터 모델
class ArtistDashboardData {
  final String walletAddress;
  final int subscriberCount;
  final int totalStreamCount;
  final int monthlyStreamCount;
  final int monthlyStreamGrowth;
  final int monthlyNewSubscribers;
  final int monthlySubscriberGrowth;
  final double monthlyRevenue;
  final int monthlyRevenueGrowth;
  final List<ChartData> subscribersChartData;
  final List<ChartData> streamsChartData;
  final List<ChartData> revenueChartData;
  // 일간 차트 데이터 추가
  final List<ChartData> dailySubscribersData;
  final List<ChartData> dailyStreamsData;
  final List<ChartData> dailyRevenueData;
  
  ArtistDashboardData({
    required this.walletAddress,
    required this.subscriberCount,
    required this.totalStreamCount,
    required this.monthlyStreamCount,
    required this.monthlyStreamGrowth,
    required this.monthlyNewSubscribers,
    required this.monthlySubscriberGrowth,
    required this.monthlyRevenue,
    required this.monthlyRevenueGrowth,
    required this.subscribersChartData,
    required this.streamsChartData,
    required this.revenueChartData,
    required this.dailySubscribersData,
    required this.dailyStreamsData,
    required this.dailyRevenueData,
  });
}

// 아티스트 대시보드 상태 관리 Notifier
class ArtistDashboardViewmodel extends StateNotifier<ArtistDashboardData> {
  ArtistDashboardViewmodel() : super(_initialData());
  
  // 초기 데이터 (실제로는 API 호출 등으로 가져올 것임)
  static ArtistDashboardData _initialData() {
    const daysInApril = 30;
    return ArtistDashboardData(
      walletAddress: 'abcdeftdfadsfasdfadfa',
      subscriberCount: 623,
      totalStreamCount: 103000,
      monthlyStreamCount: 51812,
      monthlyStreamGrowth: 100,
      monthlyNewSubscribers: 100,
      monthlySubscriberGrowth: 10,
      monthlyRevenue: 0.5,
      monthlyRevenueGrowth: 10,
      subscribersChartData: _generateMonthlyData(12, 700, 100),
      streamsChartData: _generateMonthlyData(12, 60000, 10000),
      revenueChartData: _generateMonthlyData(12, 0.8, 0.1),
      dailySubscribersData: _generateDailyData(daysInApril, 300, 20, daysInApril), 
      dailyStreamsData: _generateDailyData(daysInApril, 2000, 200, daysInApril),
      dailyRevenueData: _generateDailyData(daysInApril, 0.05, 0.01, daysInApril),
    );
  }
  
  // 월별 데이터 생성 (테스트용)
  static List<ChartData> _generateMonthlyData(int months, double maxValue, double variance) {
    final List<ChartData> result = [];
    double lastValue = maxValue / 2;
    
    for (int i = 1; i <= months; i++) {
      // 난수 생성으로 자연스러운 변동 추가
      final random = (Random().nextDouble() * 2 - 1) * variance;
      lastValue = (lastValue + random).clamp(0, maxValue);
      result.add(ChartData(i, lastValue));
    }
    
    return result;
  }

  static List<ChartData> _generateDailyData(int days, double maxValue, double variance, int maxDay) {
    final List<ChartData> result = [];
    double lastValue = maxValue * 0.8; // 시작값을 최대값의 80%로 설정
    
    for (int i = 1; i <= days; i++) {
      // 특정 패턴 생성 (초기 높고 점차 감소하는 추세)
      double trendFactor = 1.0 - (i / days) * 0.3; // 시간이 지남에 따라 감소하는 요소
      
      // 난수 생성으로 자연스러운 변동 추가 (일별 변동성)
      double dayVariation = (Random().nextDouble() * 2 - 1) * variance;
      
      // 요일별 패턴 (주말에는 살짝 감소)
      int dayOfWeek = (i % 7);
      double weekdayFactor = (dayOfWeek == 0 || dayOfWeek == 6) ? 0.9 : 1.0;
      
      // 최종 값 계산 (이전 값 기반 + 추세 + 변동)
      lastValue = (lastValue * 0.7 + maxValue * trendFactor * weekdayFactor * 0.3) + dayVariation;
      lastValue = lastValue.clamp(maxValue * 0.1, maxValue); // 값의 범위 제한
      
      // 실제 날짜가 아닌 월의 일 (1~30/31)로 저장
      result.add(ChartData(i <= maxDay ? i : maxDay, lastValue));
    }
    
    return result;
  }

  Future<void> navigateToAlbumStatList(BuildContext context) async {
    Navigator.pushNamed(context, AppRoutes.myAlbumStatList);
  }
  
  // 데이터 새로고침 (API 호출 등으로 구현)
  Future<void> refreshData() async {
    // API 호출 로직 구현 예정
    // 일단은 임의 데이터로 갱신
    state = _initialData();
  }
}

// Provider 정의
final artistDashboardProvider = StateNotifierProvider<ArtistDashboardViewmodel, ArtistDashboardData>((ref) {
  return ArtistDashboardViewmodel();
});