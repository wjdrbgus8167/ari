// 정산 아이템 (UI 화면에 표시될 항목들)
import 'package:ari/data/datasources/settlement/settlement_remote_datasources.dart';
import 'package:ari/data/models/settlement_model.dart';
import 'package:ari/data/repositories/settlement/settlement_repository.dart';
import 'package:ari/domain/repositories/settlement/settlement_repository.dart';
import 'package:ari/domain/usecases/settlement/get_settlement_history_usecase.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettlementItem {
  final String id;
  final String title;
  final String imageUrl;
  final double amount;
  final DateTime date;
  final String type; // 'streaming' or 'subscribe'

  SettlementItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.amount,
    required this.date,
    required this.type,
  });
}

// 정산 데이터 컨테이너
class SettlementData {
  final Settlement settlement;
  final List<SettlementItem> items;

  SettlementData({
    required this.settlement,
    required this.items,
  });
}

// 상태 관리를 위한 열거형
enum SettlementStatus {
  initial,
  loading,
  success,
  error,
}

// 상태 클래스
class SettlementState {
  final SettlementStatus status;
  final SettlementData? data;
  final String? errorMessage;
  final DateTime selectedDate;
  
  SettlementState({
    this.status = SettlementStatus.initial,
    this.data,
    this.errorMessage,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  // 현재 월 포맷팅 (예: 2023년 4월)
  String get currentMonth {
    return '${selectedDate.year}년 ${selectedDate.month}월';
  }

  // 상태 복사 메서드
  SettlementState copyWith({
    SettlementStatus? status,
    SettlementData? data,
    String? errorMessage,
    DateTime? selectedDate,
  }) {
    return SettlementState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

// ViewModel
class SettlementViewModel extends StateNotifier<SettlementState> {
  final SettlementUsecase _getSettlementHistory;

  SettlementViewModel(this._getSettlementHistory) : super(SettlementState()) {
    // 초기 데이터 로드
    fetchSettlementData(state.selectedDate.month);
  }

  // 이전 달로 이동
  void previousMonth() {
    final previousMonth = DateTime(
      state.selectedDate.year,
      state.selectedDate.month - 1,
      1,
    );
    state = state.copyWith(selectedDate: previousMonth);
    fetchSettlementData(previousMonth.month);
  }

  // 다음 달로 이동
  void nextMonth() {
    final nextMonth = DateTime(
      state.selectedDate.year,
      state.selectedDate.month + 1,
      1,
    );
    state = state.copyWith(selectedDate: nextMonth);
    fetchSettlementData(nextMonth.month);
  }

  // 데이터 로드
  Future<void> fetchSettlementData(int month) async {
    state = state.copyWith(status: SettlementStatus.loading);

    // UseCase 호출
    final result = await _getSettlementHistory(month);

    // Either 결과 처리
    result.fold(
      // 왼쪽(오류) 처리
      (failure) {
        state = state.copyWith(
          status: SettlementStatus.error,
          errorMessage: '데이터를 불러오는 데 실패했습니다.',
        );
      },
      // 오른쪽(성공) 처리
      (settlement) {
        // 샘플 아이템 생성 (실제로는 API에서 받아와야 함)
        final items = _createSampleItems(settlement, month);
        
        state = state.copyWith(
          status: SettlementStatus.success,
          data: SettlementData(
            settlement: settlement,
            items: items,
          ),
        );
      },
    );
  }

  // 샘플 아이템 생성 (실제 구현 시 API 응답으로 대체해야 함)
  List<SettlementItem> _createSampleItems(Settlement settlement, int month) {
    final currentYear = state.selectedDate.year;
    
    // 스트리밍 정산 아이템
    final streamingItem = SettlementItem(
      id: 'streaming-${currentYear}-${month}',
      title: '스트리밍 정산',
      imageUrl: 'https://placehold.co/30x30',
      amount: settlement.streamingSettlement,
      date: DateTime(currentYear, month, 15),
      type: 'streaming',
    );
    
    // 구독 정산 아이템
    final subscribeItem = SettlementItem(
      id: 'subscribe-${currentYear}-${month}',
      title: '구독 정산',
      imageUrl: 'https://placehold.co/30x30',
      amount: settlement.subscribeSettlement,
      date: DateTime(currentYear, month, 15),
      type: 'subscribe',
    );
    
    return [streamingItem, subscribeItem];
  }
}

// Provider
final settlementProvider = StateNotifierProvider<SettlementViewModel, SettlementState>((ref) {
  final getSettlementHistory = ref.watch(getSettlementHistoryProvider);
  return SettlementViewModel(getSettlementHistory);
});

// UseCase Provider (실제 구현 시 도메인 레이어에 위치)
final getSettlementHistoryProvider = Provider<SettlementUsecase>((ref) {
  final repository = ref.watch(settlementRepositoryProvider);
  return SettlementUsecase(repository);
});
// 이 부분은 도메인 레이어에 위치하게 됨
final settlementRepositoryProvider = Provider<SettlementRepository>((ref) {
  // 실제 구현에서는 여기에 리포지토리 구현체를 제공
  return SettlementRepositoryImpl(dataSource: ref.watch(settlementRemoteDataSourceProvider));
});
final settlementRemoteDataSourceProvider = Provider<SettlementRemoteDataSource>((ref) {
  // 실제 구현에서는 여기에 데이터 소스 구현체를 제공
  return SettlementRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});