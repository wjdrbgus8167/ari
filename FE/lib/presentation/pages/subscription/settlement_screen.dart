import 'package:ari/presentation/viewmodels/settlement/settlement_history_viewmodel.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettlementScreen extends ConsumerWidget {
  const SettlementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settlementProvider);
    final notifier = ref.read(settlementProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.black),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 부분
              HeaderWidget(
                type: HeaderType.backWithTitle, 
                title: '정산내역', 
                onBackPressed: () {
                  Navigator.pop(context);
                }
              ),
              
              // 날짜 선택 섹션 (월 선택에서 일 선택으로 변경)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 이전 날짜 버튼
                        GestureDetector(
                          onTap: () => notifier.previousDay(),
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // 현재 날짜 표시
                        Text(
                          state.currentDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // 다음 날짜 버튼
                        GestureDetector(
                          onTap: () => notifier.nextDay(),
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // 날짜 선택 아이콘 (새로 추가)
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showDatePicker(context, ref, state),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // 필터 섹션
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '전체',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: Icon(
                        Icons.filter_list,
                        color: Color(0xFFD9D9D9),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // 정산 요약 정보
              if (state.status == SettlementStatus.loaded && state.data != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.selectedDate.year}.${state.selectedDate.month}.${state.selectedDate.day} 정산 요약',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '스트리밍 정산:',
                            style: TextStyle(
                              color: Color(0xFFD9D9D9),
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '${state.data!.streamingSettlement.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '구독 정산:',
                            style: TextStyle(
                              color: Color(0xFFD9D9D9),
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '${state.data!.subscribeSettlement.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF2A2A2A), height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '총 정산액:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${state.data!.totalSettlement.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              
              // 내역 제목
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  '정산 내역',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // 내역 목록 (아직 구현되지 않음 - 현재 모델에서는 아이템 목록이 없음)
              Expanded(
                child: state.status == SettlementStatus.loading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : state.status == SettlementStatus.error
                        ? Center(
                            child: Text(
                              state.errorMessage ?? '오류가 발생했습니다',
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        : const Center(
                            child: Text(
                              '상세 정산 내역이 제공되지 않습니다',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 날짜 선택 다이얼로그
  Future<void> _showDatePicker(BuildContext context, WidgetRef ref, SettlementState state) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Color(0xFF333333),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF222222),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != state.selectedDate) {
      // 새 날짜로 데이터 로드
      ref.read(settlementProvider.notifier).fetchDailySettlement(picked);
    }
  }
}