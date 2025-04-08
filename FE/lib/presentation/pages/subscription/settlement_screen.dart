import 'package:ari/presentation/viewmodels/subscription/settlement_viewmodel.dart';
import 'package:ari/presentation/widgets/subscription/settlement_item_widget.dart';
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
              // 앱바
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(color: Colors.black),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '정산 내역',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // 월 선택 섹션
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 이전 달 버튼
                        GestureDetector(
                          onTap: () => notifier.previousMonth(),
                          child: Container(
                            transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.14),
                            width: 20,
                            height: 24,
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // 현재 월 표시
                        Text(
                          state.currentMonth,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // 다음 달 버튼
                        GestureDetector(
                          onTap: () => notifier.nextMonth(),
                          child: Container(
                            width: 20,
                            height: 20,
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // 필터 섹션
              Container(
                width: double.infinity,
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
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 15,
                      height: 15,
                      child: const Icon(
                        Icons.filter_list,
                        color: Color(0xFFD9D9D9),
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // 내역 목록
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
                        : state.data == null || state.data!.items.isEmpty
                            ? const Center(
                                child: Text(
                                  '정산 내역이 없습니다',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.data!.items.length,
                                itemBuilder: (context, index) {
                                  return SettlementItemWidget(
                                    item: state.data!.items[index],
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}