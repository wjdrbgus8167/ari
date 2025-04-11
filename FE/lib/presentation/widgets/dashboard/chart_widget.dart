import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class ChartData {
  final int x;     // X축 값 (시간별 차트에서는 시간 0-23)
  final double y;  // Y축 값 (구독자 수 또는 정산금액)

  ChartData(this.x, this.y);
}

enum ChartType { subscribers, streams, revenue }

class SimpleChartWidget extends StatelessWidget {
  final ChartType chartType;
  final List<ChartData> data;
  final bool isHourlyChart; // 시간별 표시 여부
  final String? title;

  const SimpleChartWidget({
    Key? key,
    required this.chartType,
    required this.data,
    this.isHourlyChart = false, // 기본값은 일별 차트
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Y축 최대값에 따라 좌측 여백 계산
    final maxY = _getMaxY(data);
    final yAxisWidth = _calculateYAxisWidth(maxY);

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: ShapeDecoration(
        color: const Color(0xFF373737),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 차트
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 차트 영역의 너비 계산
                  final chartWidth = constraints.maxWidth;
                  // y축 너비를 제외한 실제 바 차트 영역의 너비
                  final barChartWidth = chartWidth - yAxisWidth;

                  return Row(
                    children: [
                      // Y축 영역
                      SizedBox(width: 10),
                      // 바 차트 영역
                      SizedBox(
                        width: barChartWidth,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceBetween,
                            maxY: maxY,
                            minY: 0,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipPadding: const EdgeInsets.all(8),
                                tooltipMargin: 8,
                                getTooltipItem: (
                                  group,
                                  groupIndex,
                                  rod,
                                  rodIndex,
                                ) {
                                  final dataIndex = group.x.toInt();
                                  if (dataIndex >= 0 && dataIndex < data.length) {
                                    final value = data[dataIndex].y;
                                    final hour = data[dataIndex].x;
                                    
                                    // 차트 유형에 따라 접미사 조정
                                    String suffix = '';
                                    if (chartType == ChartType.revenue) {
                                      suffix = ' LINK';
                                    } else if (chartType == ChartType.subscribers) {
                                      suffix = '명';
                                    } else if (chartType == ChartType.streams) {
                                      suffix = '회';
                                    }
                                    
                                    // 시간별 표시
                                    final label = isHourlyChart
                                        ? '$hour시: ${value.toStringAsFixed(1)}$suffix'
                                        : '$hour일: ${value.toStringAsFixed(0)}$suffix';
                                    
                                    return BarTooltipItem(
                                      label,
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < data.length) {
                                      final xValue = data[index].x;
                                      
                                      // 시간별 모드일 때는 4시간 간격으로 표시 (0, 4, 8, 12, 16, 20)
                                      if (isHourlyChart) {
                                        if (xValue % 4 == 0 || xValue == 0 || xValue == 23) {
                                          return Text(
                                            '$xValue',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          );
                                        }
                                      } 
                                      // 일별 모드일 때는 5일 간격 + 첫날 + 마지막날
                                      else {
                                        if (xValue % 5 == 0 || xValue == 1 || xValue == 30) {
                                          return Text(
                                            '$xValue',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 20,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    // Y축에 3개의 선만 표시 (0, 중간값, 최대값)
                                    if (value == 0 ||
                                        value == maxY / 2 ||
                                        value == maxY) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 4,
                                        ),
                                        child: Text(
                                          _formatYAxisValue(value),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: yAxisWidth - 5, // 동적 계산된 너비 사용
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: maxY / 2,
                              getDrawingHorizontalLine: (value) {
                                if (value == 0 ||
                                    value == maxY / 2 ||
                                    value == maxY) {
                                  return FlLine(
                                    color: const Color(0xFFF2F2F2).withOpacity(0.3),
                                    strokeWidth: 0.5,
                                  );
                                }
                                return FlLine(
                                  color: Colors.transparent,
                                  strokeWidth: 0,
                                );
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: _getBarGroups(data),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
          // 데이터가 없는 경우 메시지 표시
          if (data.isEmpty || data.every((item) => item.y == 0))
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  '데이터가 없습니다',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Y축 숫자 포맷팅 (큰 숫자는 단위 축약)
  String _formatYAxisValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toInt().toString();
  }

  // Y축 너비 계산 (숫자 크기에 따라 조정)
  double _calculateYAxisWidth(double maxY) {
    // 숫자가 클수록 더 넓은 여백 필요
    if (maxY >= 10000) return 45;
    if (maxY >= 1000) return 40;
    if (maxY >= 100) return 35;
    return 30; // 기본 너비
  }

  // 차트의 최대 Y값 계산
  double _getMaxY(List<ChartData> data) {
    if (data.isEmpty) return 10;
    
    final maxValue = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    
    // 데이터가 전부 0이면 최소값 반환
    if (maxValue <= 0) return 10;
    
    // 적절한 스케일로 반올림
    if (maxValue <= 0.5) return 0.5;
    if (maxValue <= 1) return 1;
    if (maxValue <= 5) return 5;
    if (maxValue <= 10) return 10;
    if (maxValue <= 50) return ((maxValue ~/ 10) + 1) * 10.0;
    if (maxValue <= 100) return ((maxValue ~/ 20) + 1) * 20.0;
    if (maxValue <= 500) return ((maxValue ~/ 100) + 1) * 100.0;
    if (maxValue <= 1000) return ((maxValue ~/ 200) + 1) * 200.0;
    if (maxValue <= 10000) return ((maxValue ~/ 1000) + 1) * 1000.0;
    return ((maxValue ~/ 5000) + 1) * 5000.0;
  }

  // 차트에 표시할 막대 그룹 생성
  List<BarChartGroupData> _getBarGroups(List<ChartData> sortedData) {
    // 데이터 정렬
    List<ChartData> sortedData = List.from(data);
    sortedData.sort((a, b) => a.x.compareTo(b.x));
    
    // 시간별/일별 데이터 개수에 따라 바 너비 조정
    final int totalBars = isHourlyChart ? 24 : 31; // 시간별은 0-23시, 일별은 1-31일
    final barWidth = math.max(2.0, math.min(60.0, 200 / totalBars));
    
    return sortedData.asMap().map((index, item) {
      return MapEntry(
        index,
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: item.y,
              color: _getBarColor(),
              width: barWidth,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
          ],
        ),
      );
    }).values.toList();
  }

  // 차트 유형에 따른 색상 설정
  Color _getBarColor() {
    switch (chartType) {
      case ChartType.subscribers:
        return const Color(0xFF4ECDC4); // 청록색
      case ChartType.streams:
        return const Color(0xFF6C63FF); // 보라색
      case ChartType.revenue:
        return const Color(0xFFFFBD69); // 주황색
      default:
        return const Color(0xFF4ECDC4); // 기본 색상
    }
  }
}