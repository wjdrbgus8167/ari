import 'dart:math';

import 'package:ari/data/models/dashboard/dashboard_model.dart';
import 'package:ari/data/repositories/dashboard/dashboard_repository.dart';
import 'package:ari/domain/repositories/dashboard/dashboard_repository.dart';
import 'package:ari/domain/usecases/dashboard/get_dashboard_data_usecase.dart';
import 'package:ari/domain/usecases/my_channel/my_channel_usecases.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/dashboard/track_stat_list_viewmodel.dart';
import 'package:ari/providers/my_channel/my_channel_providers.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 아티스트 대시보드 상태 관리 Notifier
class ArtistDashboardViewmodel extends StateNotifier<ArtistDashboardData> {
  final GetArtistAlbumsUseCase getArtistAlbumsUseCase;
  final GetDashboardDataUseCase getDashboardDataUseCase;
  final String? memberId; // 현재 로그인한 멤버 ID
  
  ArtistDashboardViewmodel({
    required this.getArtistAlbumsUseCase,
    required this.getDashboardDataUseCase,
    required this.memberId,
  }) : super(_initialData());
  
  // 초기 데이터
  static ArtistDashboardData _initialData() {
    return ArtistDashboardData(
      walletAddress: "0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9",
      subscriberCount: 623,
      totalStreamingCount: 13072,
      todayStreamingCount: 518,
      streamingDiff: -10,
      todayNewSubscriberCount: 10,
      newSubscriberDiff: 5,
      todaySettlement: 19.7,
      settlementDiff: 0.8,
      todayNewSubscribeCount: 15,
      albums: [
        Album(
          albumTitle: "Midnight Blues",
          coverImageUrl: "https://example.com/covers/midnight_blues.jpg",
          trackCount: 10
        ),
        Album(
          albumTitle: "Dawn Chorus",
          coverImageUrl: "https://example.com/covers/dawn_chorus.jpg",
          trackCount: 8
        ),
      ],
      dailySubscriberCounts: _generateDailySubscriberData(),
      dailySettlement: _generateDailySettlementData(),
    );
  }
  
  // 일간 구독자 데이터 생성 (테스트용)
  static List<DailySubscriberCount> _generateDailySubscriberData() {
    final List<DailySubscriberCount> result = [];
    int baseCount = 600;
    
    for (int i = 1; i <= 8; i++) {
      // 날짜 형식: YY.MM.DD
      String date = "25.04.${i < 10 ? '0$i' : i}";
      
      // 약간의 증가세를 보이는 구독자 수
      baseCount += Random().nextInt(10) + 3;
      
      result.add(DailySubscriberCount(
        date: date,
        subscriberCount: baseCount,
      ));
    }
    
    return result;
  }

  // 일간 정산 데이터 생성 (테스트용)
  static List<DailySettlement> _generateDailySettlementData() {
    final List<DailySettlement> result = [];
    double baseSettlement = 15.0;
    
    for (int i = 1; i <= 8; i++) {
      // 날짜 형식: YY.MM.DD
      String date = "25.04.${i < 10 ? '0$i' : i}";
      
      // 변동성 있는 정산 금액
      baseSettlement += (Random().nextDouble() * 2) - 0.5;
      baseSettlement = baseSettlement.clamp(10.0, 30.0);
      
      result.add(DailySettlement(
        date: date,
        settlement: double.parse(baseSettlement.toStringAsFixed(1)), // 소수점 한 자리로 반올림
      ));
    }
    
    return result;
  }

  // 아티스트의 앨범 리스트 화면으로 이동
  Future<void> navigateToAlbumStatList(BuildContext context) async {
    Navigator.pushNamed(context, AppRoutes.myAlbumStatList);
  }
  
  // 데이터 로드 (UseCase 호출)
  Future<void> loadDashboardData() async {
    try {
      // 로딩 상태로 변경 (로딩 상태를 표시하기 위한 상태 복사본 필요)
      // 현재 ArtistDashboardData에는 isLoading 필드가 없으므로 UI에서 별도 처리 필요
      
      // 아티스트 앨범 확인
      await checkArtistHasAlbums();
      
      // 대시보드 데이터 가져오기
      final result = await getDashboardDataUseCase();
      
      // Either 결과 처리
      result.fold(
        // 실패 케이스 (Left)
        (failure) {
          // 오류 처리 (오류 메시지 표시 등)
          // 현재 ArtistDashboardData에는 errorMessage 필드가 없으므로 UI에서 별도 처리 필요
        },
        // 성공 케이스 (Right)
        (dashboardData) {
          // 데이터 업데이트
          state = dashboardData;
          print("Dashboard data loaded successfully: $dashboardData");
        },
      );
    } catch (e) {
      // 예외 처리
      // UI에서 에러 표시 필요
    }
  }
  
  // 데이터 새로고침
  Future<void> refreshData() async {
    await loadDashboardData();
  }
  
  // 아티스트가 앨범을 가지고 있는지 확인하는 메서드
  Future<bool> checkArtistHasAlbums() async {
    try {
      // UseCase 호출
      if (memberId == null) {
        return false;
      }

      final result = await getArtistAlbumsUseCase.execute(memberId ?? '1');
      
      // Either 결과 처리
      return result.fold(
        // 실패 케이스 (Left)
        (failure) {
          return false;
        },
        // 성공 케이스 (Right)
        (albums) {
          return albums.isNotEmpty;
        },
      );
    } catch (e) {
      return false;
    }
  }

  // 지갑 주소 설정 메서드
  Future<bool> setWalletAddress(String walletAddress) async {
    try {
      // 지갑 주소 유효성 검사
      if (walletAddress.isEmpty) {
        return false;
      }
      
      // 지갑 주소 형식 검사
      if (!_isValidWalletAddress(walletAddress)) {
        return false;
      }
      
      // 지갑 주소 업데이트
      state = ArtistDashboardData(
        walletAddress: walletAddress,
        subscriberCount: state.subscriberCount,
        totalStreamingCount: state.totalStreamingCount,
        todayStreamingCount: state.todayStreamingCount,
        streamingDiff: state.streamingDiff,
        todayNewSubscriberCount: state.todayNewSubscriberCount,
        newSubscriberDiff: state.newSubscriberDiff,
        todaySettlement: state.todaySettlement,
        settlementDiff: state.settlementDiff,
        todayNewSubscribeCount: state.todayNewSubscribeCount,
        albums: state.albums,
        dailySubscriberCounts: state.dailySubscriberCounts,
        dailySettlement: state.dailySettlement,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // 지갑 주소 유효성 검사 메서드 (예: 이더리움 주소 형식 검사)
  bool _isValidWalletAddress(String address) {
    // 이더리움 주소 형식 검사 (0x로 시작하고 40자리 16진수)
    final regex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return regex.hasMatch(address);
  }
  
  // ArtistDashboardData를 서버 응답 데이터로부터 생성
  ArtistDashboardData createFromResponse(Map<String, dynamic> responseData) {
    try {
      return ArtistDashboardData.fromJson(responseData);
    } catch (e) {
      // 파싱 오류 시 기본 데이터 반환
      return _initialData();
    }
  }
}

// Riverpod Provider 정의
final artistDashboardProvider = StateNotifierProvider<ArtistDashboardViewmodel, ArtistDashboardData>((ref) {
  // memberId 초기화
  final memberId = ref.read(userIdProvider);
  
  return ArtistDashboardViewmodel(
    getArtistAlbumsUseCase: ref.read(getArtistAlbumsUseCaseProvider),
    getDashboardDataUseCase: ref.read(getDashboardDataUseCaseProvider),
    memberId: memberId,
  );
});

// GetDashboardDataUseCase Provider 정의
final getDashboardDataUseCaseProvider = Provider<GetDashboardDataUseCase>((ref) {
  final repository = ref.read(dashboardRepositoryProvider);
  return GetDashboardDataUseCase(repository);
});

// DashboardRepository Provider 정의 (실제 구현 필요)
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  // 실제 구현체 반환
  return DashboardRepositoryImpl(dataSource: ref.read(dashboardDataSourceProvider));
});
