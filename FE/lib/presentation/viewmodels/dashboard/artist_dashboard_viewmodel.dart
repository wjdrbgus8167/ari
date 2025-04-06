import 'dart:math';

import 'package:ari/domain/usecases/my_channel/my_channel_usecases.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/widgets/dashboard/chart_widget.dart';
import 'package:ari/providers/my_channel/my_channel_providers.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 아티스트 대시보드 데이터 모델 (hasTracks 추가)
class ArtistDashboardData {
  final String? walletAddress;
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
  final bool isLoading; // 데이터 로딩 상태
  final bool hasTracks; // 아티스트가 트랙을 가지고 있는지 여부
  final String? errorMessage; // 오류 메시지

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
    this.isLoading = false,
    this.hasTracks = false,
    this.errorMessage,
  });

  // 복사 메서드 추가
  ArtistDashboardData copyWith({
    String? walletAddress,
    int? subscriberCount,
    int? totalStreamCount,
    int? monthlyStreamCount,
    int? monthlyStreamGrowth,
    int? monthlyNewSubscribers,
    int? monthlySubscriberGrowth,
    double? monthlyRevenue,
    int? monthlyRevenueGrowth,
    List<ChartData>? subscribersChartData,
    List<ChartData>? streamsChartData,
    List<ChartData>? revenueChartData,
    List<ChartData>? dailySubscribersData,
    List<ChartData>? dailyStreamsData,
    List<ChartData>? dailyRevenueData,
    bool? isLoading,
    bool? hasTracks,
    String? errorMessage,
  }) {
    return ArtistDashboardData(
      walletAddress: walletAddress ?? this.walletAddress,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      totalStreamCount: totalStreamCount ?? this.totalStreamCount,
      monthlyStreamCount: monthlyStreamCount ?? this.monthlyStreamCount,
      monthlyStreamGrowth: monthlyStreamGrowth ?? this.monthlyStreamGrowth,
      monthlyNewSubscribers: monthlyNewSubscribers ?? this.monthlyNewSubscribers,
      monthlySubscriberGrowth: monthlySubscriberGrowth ?? this.monthlySubscriberGrowth,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      monthlyRevenueGrowth: monthlyRevenueGrowth ?? this.monthlyRevenueGrowth,
      subscribersChartData: subscribersChartData ?? this.subscribersChartData,
      streamsChartData: streamsChartData ?? this.streamsChartData,
      revenueChartData: revenueChartData ?? this.revenueChartData,
      dailySubscribersData: dailySubscribersData ?? this.dailySubscribersData,
      dailyStreamsData: dailyStreamsData ?? this.dailyStreamsData,
      dailyRevenueData: dailyRevenueData ?? this.dailyRevenueData,
      isLoading: isLoading ?? this.isLoading,
      hasTracks: hasTracks ?? this.hasTracks,
      errorMessage: errorMessage,
    );
  }
}

// 아티스트 대시보드 상태 관리 Notifier
class ArtistDashboardViewmodel extends StateNotifier<ArtistDashboardData> {
  final GetArtistAlbumsUseCase getArtistAlbumsUseCase;
  final String? memberId; // 현재 로그인한 멤버 ID
  
  ArtistDashboardViewmodel({
    required this.getArtistAlbumsUseCase,
    required this.memberId,
  }) : super(_initialData());
  
  // 초기 데이터 (실제로는 API 호출 등으로 가져올 것임)
  static ArtistDashboardData _initialData() {
    const daysInApril = 30;
    return ArtistDashboardData(
      walletAddress: null,
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

  // 아티스트의 앨범 리스트 화면으로 이동
  Future<void> navigateToAlbumStatList(BuildContext context) async {
    Navigator.pushNamed(context, AppRoutes.myAlbumStatList);
  }
  
  // 데이터 새로고침 (API 호출 등으로 구현)
  Future<void> refreshData() async {
    // 로딩 상태로 변경
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // 아티스트 앨범 확인
    await checkArtistHasAlbums();
    
    // API 호출 로직 구현 예정
    // 현재는 임의 데이터로 갱신
    state = _initialData().copyWith(
      isLoading: false,
      hasTracks: state.hasTracks, // checkArtistHasAlbums에서 설정한 값 유지
    );
  }

  // 아티스트가 앨범을 가지고 있는지 확인하는 메서드
  Future<bool> checkArtistHasAlbums() async {
    try {
      // 로딩 상태로 변경
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // UseCase 호출
      if (memberId == null) {
        state = state.copyWith(
          isLoading: false, 
          hasTracks: false,
          errorMessage: 'Member ID is null',
        );
        return false;
      }

      final result = await getArtistAlbumsUseCase.execute(memberId ?? '1');
      
      // Either 결과 처리
      return result.fold(
        // 실패 케이스 (Left)
        (failure) {
          state = state.copyWith(
            isLoading: false, 
            hasTracks: false,
            errorMessage: failure.message,
          );
          return false;
        },
        // 성공 케이스 (Right)
        (albums) {
          final hasAlbums = albums.isNotEmpty;
          state = state.copyWith(
            isLoading: false, 
            hasTracks: hasAlbums,
            errorMessage: null,
          );
          return hasAlbums;
        },
      );
    } catch (e) {
      // 예외 처리
      state = state.copyWith(
        isLoading: false, 
        hasTracks: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // 지갑 주소 설정 메서드
  Future<bool> setWalletAddress(String walletAddress) async {
    try {
      // 지갑 주소 유효성 검사 (필요한 경우)
      if (walletAddress.isEmpty) {
        state = state.copyWith(
          errorMessage: '지갑 주소를 입력해주세요.'
        );
        return false;
      }
      
      // 지갑 주소 형식 검사 (예: 이더리움 주소 형식 0x로 시작하는지 등)
      if (!_isValidWalletAddress(walletAddress)) {
        state = state.copyWith(
          errorMessage: '유효하지 않은 지갑 주소입니다.'
        );
        return false;
      }
      
      // TODO: 서버에 지갑 주소 저장 API 호출 (실제 구현 필요)
      // 예: final result = await walletRepository.saveWalletAddress(memberId, walletAddress);
      
      // 임시로 성공한 것으로 처리 (실제로는 API 응답에 따라 처리)
      state = state.copyWith(
        walletAddress: walletAddress,
        errorMessage: null,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: '지갑 주소 등록 중 오류가 발생했습니다: ${e.toString()}'
      );
      return false;
    }
  }

  // 지갑 주소 유효성 검사 메서드 (예: 이더리움 주소 형식 검사)
  bool _isValidWalletAddress(String address) {
    // 이더리움 주소 형식 검사 (0x로 시작하고 40자리 16진수)
    final regex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return regex.hasMatch(address);
  }
  
}

// Provider 정의
final artistDashboardProvider = StateNotifierProvider<ArtistDashboardViewmodel, ArtistDashboardData>((ref) {
  // memberId는 인증 상태나 사용자 세션에서 가져와야 함
  // 이 부분은 실제 인증 로직에 맞게 수정 필요
  
  return ArtistDashboardViewmodel(
    getArtistAlbumsUseCase: ref.read(getArtistAlbumsUseCaseProvider),
    memberId: ref.read(userIdProvider),
  );
});