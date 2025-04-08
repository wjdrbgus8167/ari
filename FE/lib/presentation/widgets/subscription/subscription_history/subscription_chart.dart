// widgets/subscription/subscription_chart.dart
import 'package:ari/data/models/subscription/regular_subscription_models.dart';
import 'package:ari/presentation/viewmodels/subscription/regular_subscription_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SubscriptionChart extends StatelessWidget {
  final List<ArtistAllocation> artistAllocations;

  const SubscriptionChart({Key? key, required this.artistAllocations})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160, // 전체 높이
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 그래프 위젯
          PieChart(
            PieChartData(
              sectionsSpace: 1, // 약간의 간격 추가
              centerSpaceRadius: 50, // 중앙 공간 크기 조절
              sections: _createPieChartSections(),
              // 애니메이션 효과 추가
              pieTouchData: PieTouchData(enabled: false), // 터치 비활성화
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections() {
    return artistAllocations.map((allocation) {
      return PieChartSectionData(
        color: allocation.color,
        value: allocation.allocation,
        title: '', // 차트 내부에 텍스트 표시 안 함
        radius: 70, // 반지름 크기
        titleStyle: TextStyle(
          fontSize: 0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
