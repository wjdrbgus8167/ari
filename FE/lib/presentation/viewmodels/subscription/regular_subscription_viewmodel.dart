// ViewModel 클래스
import 'package:ari/data/models/subscription/regular_subscription_models.dart';
import 'package:ari/domain/usecases/subscription/subscription_history_usecase.dart';
import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegularSubscriptionState {
  final bool isLoading;
  final String? errorMessage;
  final List<SubscriptionCycle> cycles;
  final SubscriptionCycle? selectedCycle;
  final RegularSubscriptionDetail? subscriptionDetail;
  final bool showAllArtists;
  
  RegularSubscriptionState({
    this.isLoading = false,
    this.errorMessage,
    this.cycles = const [],
    this.selectedCycle,
    this.subscriptionDetail,
    this.showAllArtists = false,
  });
  
  // 표시할 아티스트 목록 (더보기 기능을 위한 계산된 프로퍼티)
  List<ArtistSettlement> get displaySettlements {
    if (subscriptionDetail == null) return [];
    if (showAllArtists) return subscriptionDetail!.settlements;
    return subscriptionDetail!.settlements.length > 3 
        ? subscriptionDetail!.settlements.sublist(0, 3) 
        : subscriptionDetail!.settlements;
  }
  
  // 총 결제 금액 (필요하다면)
  double get totalSettlement {
    if (subscriptionDetail == null) return 0.0;
    return subscriptionDetail!.settlements.fold(
      0.0, (sum, item) => sum + item.settlement);
  }
  
  // 아티스트별 할당 비율 계산 (차트에 사용)
  List<ArtistAllocation> get artistAllocations {
    if (subscriptionDetail == null) return [];
    
    final total = totalSettlement;
    if (total <= 0) return [];
    
    return subscriptionDetail!.settlements.map((settlement) {
      final percentage = (settlement.settlement / total) * 100;
      
      // 차트용 색상 할당 (실제 앱에서는 더 체계적인 색상 관리가 필요할 수 있음)
      final Color color = _getColorForIndex(
        subscriptionDetail!.settlements.indexOf(settlement));
      
      return ArtistAllocation(
        artistNickname: settlement.artistNickname,
        profileImageUrl: settlement.profileImageUrl,
        streamingCount: settlement.streamingCount,
        allocation: percentage,
        color: color,
      );
    }).toList();
  }
  
  // 간단한 색상 할당 함수 (실제 구현에서는 더 나은 방식으로 대체할 수 있음)
  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF2563EB), // 파란색
      const Color(0xFFC084FC), // 보라색
      const Color(0xFF10B981), // 초록색
      const Color(0xFFF59E0B), // 주황색
      const Color(0xFFEF4444), // 빨간색
    ];
    
    return colors[index % colors.length];
  }
  
  // 복사본 생성
  RegularSubscriptionState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SubscriptionCycle>? cycles,
    SubscriptionCycle? selectedCycle,
    RegularSubscriptionDetail? subscriptionDetail,
    bool? showAllArtists,
  }) {
    return RegularSubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      cycles: cycles ?? this.cycles,
      selectedCycle: selectedCycle ?? this.selectedCycle,
      subscriptionDetail: subscriptionDetail ?? this.subscriptionDetail,
      showAllArtists: showAllArtists ?? this.showAllArtists,
    );
  }
}

// 차트용 아티스트 할당 모델
class ArtistAllocation {
  final String artistNickname;
  final String profileImageUrl;
  final int streamingCount;
  final double allocation; // 백분율
  final Color color;
  
  ArtistAllocation({
    required this.artistNickname,
    required this.profileImageUrl,
    required this.streamingCount,
    required this.allocation,
    required this.color,
  });
}

class RegularSubscriptionViewModel extends StateNotifier<RegularSubscriptionState> {
  final SubscriptionCycleUsecase _cycleUsecase;
  final RegularSubscriptionDetailUsecase _detailUsecase;
  
  RegularSubscriptionViewModel(this._cycleUsecase, this._detailUsecase) 
      : super(RegularSubscriptionState());
  
  // 초기 데이터 로드
  Future<void> loadSubscriptionCycles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _cycleUsecase();
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '구독 주기 정보를 불러오는 중 오류가 발생했습니다: ${failure.message}',
        );
      },
      (cycles) {
        if (cycles.isNotEmpty) {
          state = state.copyWith(
            isLoading: false,
            cycles: cycles,
            selectedCycle: cycles.first, // 기본적으로 가장 최근 주기 선택
          );
          
          // 선택된 주기에 대한 상세 정보 로드
          loadSubscriptionDetail(cycles.first.cycleId);
        } else {
          state = state.copyWith(
            isLoading: false,
            cycles: cycles,
          );
        }
      }
    );
  }
  
  // 특정 주기에 대한 상세 정보 로드
  Future<void> loadSubscriptionDetail(int cycleId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _detailUsecase(cycleId);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '구독 상세 정보를 불러오는 중 오류가 발생했습니다: ${failure.message}',
        );
      },
      (detail) {
        // 해당 주기 객체 찾기
        final selectedCycle = state.cycles.firstWhere(
          (cycle) => cycle.cycleId == cycleId,
          orElse: () => state.selectedCycle!,
        );
        
        state = state.copyWith(
          isLoading: false,
          selectedCycle: selectedCycle,
          subscriptionDetail: detail,
        );
      }
    );
  }
  
  // 주기 변경 처리
  void selectCycle(SubscriptionCycle cycle) {
    if (state.selectedCycle?.cycleId != cycle.cycleId) {
      loadSubscriptionDetail(cycle.cycleId);
    }
  }
  
  // 모든 아티스트 보기/숨기기 토글
  void toggleShowAllArtists() {
    state = state.copyWith(showAllArtists: !state.showAllArtists);
  }
}

// UseCase Provider 정의 (Repository 주입)
final subscriptionCycleUsecaseProvider = Provider<SubscriptionCycleUsecase>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionCycleUsecase(repository);
});

final regularSubscriptionDetailUsecaseProvider = Provider<RegularSubscriptionDetailUsecase>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return RegularSubscriptionDetailUsecase(repository);
});

// Provider 정의
final regularSubscriptionViewModelProvider =
    StateNotifierProvider<RegularSubscriptionViewModel, RegularSubscriptionState>((ref) {
  final cycleUsecase = ref.watch(subscriptionCycleUsecaseProvider);
  final detailUsecase = ref.watch(regularSubscriptionDetailUsecaseProvider);
  return RegularSubscriptionViewModel(cycleUsecase, detailUsecase);
});