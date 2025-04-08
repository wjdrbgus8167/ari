import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import 'package:intl/intl.dart';

enum ChartType { subscribers, streams, revenue }

enum ChartPeriod {
  daily,
  monthly,
}

class ChartData {
  final int x; // x축 값 (일간 데이터의 경우 1-31, 월간 데이터의 경우 1-12)
  final double y; // y축 값

  ChartData(this.x, this.y);
}

class ChartWidget extends StatefulWidget {
  final ChartType chartType;
  final List<ChartData> data;
  final String? title;

  const ChartWidget({
    super.key,
    required this.chartType,
    required this.data,
    this.title,
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  ChartPeriod _currentPeriod = ChartPeriod.daily;
  int _selectedYear = 2025;
  int _selectedMonth = 4; // 기본값은 4월 (0-베이스가 아닌 1-베이스)

  @override
  Widget build(BuildContext context) {
    // 데이터 준비
    List<ChartData> currentData = widget.data;
    
    // 날짜 포맷터
    final monthFormat = DateFormat('M월');
    
    // Y축 최대값에 따라 좌측 여백 계산
    final maxY = _getMaxY(currentData);
    final yAxisWidth = _calculateYAxisWidth(maxY);

    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
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
          // 상단 선택기
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽: 기간 선택 드롭다운
              DropdownButton<ChartPeriod>(
                value: _currentPeriod,
                dropdownColor: const Color(0xFF373737),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                underline: Container(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currentPeriod = newValue;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(value: ChartPeriod.daily, child: Text('일간')),
                  DropdownMenuItem(
                    value: ChartPeriod.monthly,
                    child: Text('월간'),
                  ),
                ],
              ),
              
              // 오른쪽: 년도 및 월 선택 컨트롤
              Row(
                children: [
                  // 년도 선택
                  Text(
                    '$_selectedYear년',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  
                  // 월 선택 네비게이션 (일간 모드일 때만 표시)
                  if (_currentPeriod == ChartPeriod.daily)
                    Container(
                      decoration: BoxDecoration(
                      ),
                      child: Row(
                        children: [
                          // 이전 월 버튼
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 12, color: Colors.white),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            constraints: const BoxConstraints(),
                            onPressed: _selectedMonth > 1 
                              ? () => setState(() => _selectedMonth--) 
                              : null,
                          ),
                          // 현재 선택된 월
                          Text(
                            '$_selectedMonth월',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // 다음 월 버튼
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            constraints: const BoxConstraints(),
                            onPressed: _selectedMonth < 12 
                              ? () => setState(() => _selectedMonth++) 
                              : null,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 차트
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
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
                                  if (dataIndex >= 0 && dataIndex < currentData.length) {
                                    final value = currentData[dataIndex].y;
                                    final dayOrMonth = currentData[dataIndex].x;
                                    
                                    // 차트 유형에 따라 접미사 조정
                                    String suffix = '';
                                    if (widget.chartType == ChartType.revenue) {
                                      suffix = ' USD';
                                    } else if (widget.chartType == ChartType.subscribers) {
                                      suffix = '명';
                                    } else if (widget.chartType == ChartType.streams) {
                                      suffix = '회';
                                    }
                                    
                                    final label = _currentPeriod == ChartPeriod.monthly 
                                        ? '$dayOrMonth월: ${value.toStringAsFixed(0)}$suffix'
                                        : '$dayOrMonth일: ${value.toStringAsFixed(0)}$suffix';
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
                                    if (index >= 0 && index < currentData.length) {
                                      final unit = currentData[index].x;
                                      // 월간/일간 모드에 따라 라벨 조정
                                      if (_currentPeriod == ChartPeriod.monthly) {
                                        // 월간 모드는 격월 표시 (1월, 3월, 5월 등)
                                        if (unit % 2 == 1) {
                                          return Text(
                                            '$unit',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          );
                                        }
                                      } else {
                                        // 일간 모드는 5일 간격 + 첫날
                                        if (unit % 5 == 0 || unit == 1) {
                                          return Text(
                                            '$unit',
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
                                    color: const Color(
                                      0xFFF2F2F2,
                                    ).withOpacity(0.3),
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
                            barGroups: _getBarGroups(currentData),
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
          if (currentData.isEmpty)
            const Center(
              child: Text(
                '해당 월의 데이터가 없습니다',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
    if (data.isEmpty) return 300;
    
    final maxValue = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    
    // 적절한 스케일로 반올림
    if (maxValue <= 10) return 10;
    if (maxValue <= 50) return ((maxValue ~/ 10) + 1) * 10.0;
    if (maxValue <= 100) return ((maxValue ~/ 20) + 1) * 20.0;
    if (maxValue <= 500) return ((maxValue ~/ 100) + 1) * 100.0;
    if (maxValue <= 1000) return ((maxValue ~/ 200) + 1) * 200.0;
    if (maxValue <= 10000) return ((maxValue ~/ 1000) + 1) * 1000.0;
    return ((maxValue ~/ 5000) + 1) * 5000.0;
  }

  // 차트에 표시할 막대 그룹 생성
  List<BarChartGroupData> _getBarGroups(List<ChartData> data) {
    // 데이터 개수에 따라 바 너비 조정 (데이터가 많을수록 좁게)
    final barWidth = math.max(2.0, math.min(60.0, 200 / data.length));
    
    return data.asMap().map((index, item) {
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
    switch (widget.chartType) {
      case ChartType.subscribers:
        return const Color(0xFF4ECDC4); // 청록색
      case ChartType.streams:
        return const Color(0xFF6C63FF); // 보라색
      case ChartType.revenue:
        return const Color(0xFFFFBD69); // 주황색
    }
  }
}
