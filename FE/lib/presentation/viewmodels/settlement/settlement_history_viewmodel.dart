// 상태 관리를 위한 열거형
import 'package:ari/data/datasources/settlement/settlement_remote_datasources.dart';
import 'package:ari/data/models/settlement_model.dart';
import 'package:ari/data/repositories/settlement/settlement_repository.dart';
import 'package:ari/domain/repositories/settlement/settlement_repository.dart';
import 'package:ari/domain/usecases/settlement/get_settlement_history_usecase.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SettlementStatus {
  initial,
  loading,
  loaded,
  error,
}

// 상태 클래스
class SettlementState {
  final SettlementStatus status;
  final Settlement? data;
  final String? errorMessage;
  final DateTime selectedDate;
  
  SettlementState({
    this.status = SettlementStatus.initial,
    this.data,
    this.errorMessage,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  // 현재 날짜 포맷팅 (예: 2023.4.15)
  String get currentDate {
    return '${selectedDate.year}.${selectedDate.month}.${selectedDate.day}';
  }

  // 상태 복사 메서드
  SettlementState copyWith({
    SettlementStatus? status,
    Settlement? data,
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
  final SettlementUsecase _settlementUsecase;

  SettlementViewModel(this._settlementUsecase) : super(SettlementState()) {
    // 초기 데이터 로드 - 오늘 날짜 기준
    fetchDailySettlement(state.selectedDate);
  }

  // 전날로 이동
  void previousDay() {
    final previousDay = state.selectedDate.subtract(const Duration(days: 1));
    state = state.copyWith(selectedDate: previousDay);
    fetchDailySettlement(previousDay);
  }

  // 다음날로 이동
  void nextDay() {
    final nextDay = state.selectedDate.add(const Duration(days: 1));
    state = state.copyWith(selectedDate: nextDay);
    fetchDailySettlement(nextDay);
  }

  // 일별 정산 데이터 로드
  Future<void> fetchDailySettlement(DateTime date) async {
    state = state.copyWith(status: SettlementStatus.loading);

    try {
      // UseCase 호출 (일별 정산 데이터 요청)
      final result = await _settlementUsecase(date.year, date.month, date.day);

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
          state = state.copyWith(
            status: SettlementStatus.loaded,
            data: settlement,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: SettlementStatus.error,
        errorMessage: '데이터를 불러오는 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
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