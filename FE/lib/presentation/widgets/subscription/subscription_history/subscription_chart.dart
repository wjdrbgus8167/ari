// widgets/subscription/subscription_chart.dart
import 'package:ari/data/models/subscription_history_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SubscriptionChart extends StatelessWidget {
  final List<Artist> artists;
  
  const SubscriptionChart({
    Key? key,
    required this.artists,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: _createPieChartSections(),
        ),
      ),
    );
  }
  
  List<PieChartSectionData> _createPieChartSections() {
    return artists.map((artist) {
      return PieChartSectionData(
        color: artist.color,
        value: artist.allocation.toDouble(),
        title: '', // 차트 내부에 표시할 텍스트 없음
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 0,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    }).toList();
  }
}