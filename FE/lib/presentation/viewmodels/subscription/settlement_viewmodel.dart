import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SettlementStatus {
  initial,
  loading,
  loaded,
  error,
}

class SettlementState {
  final SettlementStatus status;
  final SettlementData? data;
  final String? errorMessage;
  final String currentMonth;

  SettlementState({
    this.status = SettlementStatus.initial,
    this.data,
    this.errorMessage,
    this.currentMonth = '3월',
  });

  SettlementState copyWith({
    SettlementStatus? status,
    SettlementData? data,
    String? errorMessage,
    String? currentMonth,
  }) {
    return SettlementState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
      currentMonth: currentMonth ?? this.currentMonth,
    );
  }
}

class SettlementItem {
  final String title;
  final double amount;
  final String imageUrl;

  SettlementItem({
    required this.title,
    required this.amount,
    required this.imageUrl,
  });
}

class SettlementData {
  final String month;
  final List<SettlementItem> items;

  SettlementData({
    required this.month,
    required this.items,
  });
}

class SettlementNotifier extends StateNotifier<SettlementState> {
  SettlementNotifier() : super(SettlementState()) {
    loadSettlementData();
  }

  Future<void> loadSettlementData() async {
    try {
      state = state.copyWith(
        status: SettlementStatus.loading,
      );

      // 실제 API 호출 대신 더미 데이터를 사용합니다.
      await Future.delayed(const Duration(seconds: 1));
      
      final dummyData = SettlementData(
        month: state.currentMonth,
        items: [
          SettlementItem(
            title: '음원 수익',
            amount: 0.24,
            imageUrl: 'https://placehold.co/30x30',
          ),
          SettlementItem(
            title: '아티스트 구독 수익',
            amount: 0.24,
            imageUrl: 'https://placehold.co/30x30',
          ),
        ],
      );

      state = state.copyWith(
        status: SettlementStatus.loaded,
        data: dummyData,
      );
    } catch (e) {
      state = state.copyWith(
        status: SettlementStatus.error,
        errorMessage: '정산 내역을 불러오는데 실패했습니다: $e',
      );
    }
  }

  void changeMonth(String month) {
    state = state.copyWith(currentMonth: month);
    loadSettlementData();
  }

  // 이전 달로 변경
  void previousMonth() {
    // 실제 구현에서는 월 계산 로직을 추가하세요
    // 예: '3월' -> '2월'
    changeMonth('2월');
  }

  // 다음 달로 변경
  void nextMonth() {
    // 실제 구현에서는 월 계산 로직을 추가하세요
    // 예: '3월' -> '4월'
    changeMonth('4월');
  }
}

final settlementProvider = StateNotifierProvider<SettlementNotifier, SettlementState>((ref) {
  return SettlementNotifier();
});