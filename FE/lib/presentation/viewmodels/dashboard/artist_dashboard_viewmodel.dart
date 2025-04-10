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
  final HasWalletUseCase hasWalletUseCase; 
  bool _isLoadingData = true;

  ArtistDashboardViewmodel({
    required this.getArtistAlbumsUseCase,
    required this.getDashboardDataUseCase,
    required this.memberId,
    required this.hasWalletUseCase,
  }) : super(_initialData());
  
  // 초기 데이터
  static ArtistDashboardData _initialData() {
    return ArtistDashboardData(
      walletAddress: '',
      subscriberCount: 0,
      totalStreamingCount: 0,
      todayStreamingCount: 0,
      streamingDiff: 0,
      todayNewSubscriberCount: 0,
      newSubscriberDiff: 0,
      todaySettlement: 0,
      settlementDiff: 0,
      todayNewSubscribeCount: 0,
      albums: [],
      dailySubscriberCounts: [],
      dailySettlement: [],
      monthlySubscriberCounts: [],
    );
  }
  
  // 아티스트의 앨범 리스트 화면으로 이동
  Future<void> navigateToAlbumStatList(BuildContext context) async {
    Navigator.pushNamed(context, AppRoutes.myAlbumStatList);
  }
  
  // 로딩 상태 getter
  bool get isLoadingData => _isLoadingData;

  // 데이터 로드 (UseCase 호출)
  Future<void> loadDashboardData() async {
    try {
      // 로딩 상태로 변경 (로딩 상태를 표시하기 위한 상태 복사본 필요)
      _isLoadingData = true;
      // 현재 ArtistDashboardData에는 isLoading 필드가 없으므로 UI에서 별도 처리 필요
      
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
    } finally {
      // 로딩 상태 해제
      _isLoadingData = false;
    }
  }
  Future<bool> hasWallet() async {
      final result = await hasWalletUseCase();
      return result.fold(
        (failure) {
          debugPrint('지갑 여부 가져오기 실패: ${failure.message}');
          return false;
        },
        (hasWalletModel) {
          debugPrint('지갑 여부: $hasWallet');
          return hasWalletModel.hasWallet; // hasWallet 값 직접 반환
        },
      );
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
        monthlySubscriberCounts: state.monthlySubscriberCounts,
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
  
}

// Riverpod Provider 정의
final artistDashboardProvider = StateNotifierProvider<ArtistDashboardViewmodel, ArtistDashboardData>((ref) {
  // memberId 초기화
  final memberId = ref.read(userIdProvider);
  
  return ArtistDashboardViewmodel(
    getArtistAlbumsUseCase: ref.read(getArtistAlbumsUseCaseProvider),
    getDashboardDataUseCase: ref.read(getDashboardDataUseCaseProvider),
    memberId: memberId,
    hasWalletUseCase: ref.read(hasWalletUseCaseProvider),
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
