import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

enum ChartType {
  subscribers,
  streams,
  revenue,
}

enum ChartPeriod {
  daily,
  monthly,
  yearly,
}

class ChartData {
  final int day; // 일간 데이터의 경우 1-31, 월간 데이터의 경우 1-12
  final double value;

  ChartData(this.day, this.value);
}

class ChartWidget extends StatefulWidget {
  final ChartType chartType;
  final List<ChartData> data;
  final List<ChartData>? monthlyData; // 월간 데이터 추가
  final String? title;

  const ChartWidget({
    super.key,
    required this.chartType,
    required this.data,
    this.monthlyData,
    this.title,
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  ChartPeriod _currentPeriod = ChartPeriod.daily;
  int _selectedYear = 2025;
  int _selectedMonth = 4;

  @override
  Widget build(BuildContext context) {
    // 현재 기간에 따른 적절한 데이터 선택
    List<ChartData> currentData;
    
    if (_currentPeriod == ChartPeriod.monthly) {
      // 월간 모드: 1~12월 데이터
      if (widget.monthlyData != null) {
        // 이미 준비된 월간 데이터가 있다면 사용
        currentData = widget.monthlyData!;
      } else {
        // 기존 일간 데이터로부터 월간 데이터 생성 (같은 월의 데이터는 합산)
        // 예: 1월의 모든 일간 데이터를 더해서 1월 데이터 생성
        Map<int, double> monthlyValues = {};
        
        for (var item in widget.data) {
          // 일간 데이터에서 월 정보 추출 (1~31일 데이터에서의 '월' 정보는 항상 1로 가정)
          int month = 1;
          
          // 각 월별로 데이터 합산
          if (monthlyValues.containsKey(month)) {
            monthlyValues[month] = monthlyValues[month]! + item.value;
          } else {
            monthlyValues[month] = item.value;
          }
        }
        
        // 월간 데이터로 변환
        currentData = monthlyValues.entries
            .map((entry) => ChartData(entry.key, entry.value))
            .toList();
        
        // 월 번호순으로 정렬
        currentData.sort((a, b) => a.day.compareTo(b.day));
        
        // 1~12월 데이터가 모두 있는지 확인하고 없는 월은 0으로 채우기
        List<ChartData> completeMonthlyData = [];
        for (int month = 1; month <= 12; month++) {
          final monthData = currentData.firstWhere(
            (item) => item.day == month, 
            orElse: () => ChartData(month, 0)
          );
          completeMonthlyData.add(monthData);
        }
        
        currentData = completeMonthlyData;
      }
    } else if (_currentPeriod == ChartPeriod.yearly) {
      // 연간 모드 로직 (필요시 구현)
      // 일단은 모든 일간 데이터를 표시
      currentData = widget.data;
    } else {
      // 일간 모드: 선택된 년/월에 해당하는 일간 데이터만 필터링
      final lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      currentData = widget.data.where((item) => item.day <= lastDayOfMonth).toList();
    }

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
          )
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
                  DropdownMenuItem(
                    value: ChartPeriod.daily,
                    child: Text('일간'),
                  ),
                  DropdownMenuItem(
                    value: ChartPeriod.monthly,
                    child: Text('월간'),
                  ),
                  DropdownMenuItem(
                    value: ChartPeriod.yearly,
                    child: Text('연간'),
                  ),
                ],
              ),
              
              // 오른쪽: 년도 및 월 선택 드롭다운
              Row(
                children: [
                  // 년도 선택 드롭다운
                  DropdownButton<int>(
                    value: _selectedYear,
                    dropdownColor: const Color(0xFF373737),
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    underline: Container(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedYear = newValue;
                        });
                      }
                    },
                    items: List<DropdownMenuItem<int>>.generate(
                      5,
                      (index) => DropdownMenuItem(
                        value: 2025 - index,
                        child: Text('${2025 - index}년'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 월 선택 드롭다운 (일간 모드일 때만 표시)
                  if (_currentPeriod == ChartPeriod.daily)
                    DropdownButton<int>(
                      value: _selectedMonth,
                      dropdownColor: const Color(0xFF373737),
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      underline: Container(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedMonth = newValue;
                          });
                        }
                      },
                      items: List<DropdownMenuItem<int>>.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}월'),
                        ),
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
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final dataIndex = group.x.toInt();
                                  if (dataIndex >= 0 && dataIndex < currentData.length) {
                                    final value = currentData[dataIndex].value;
                                    final label = _currentPeriod == ChartPeriod.monthly 
                                        ? '${currentData[dataIndex].day}월: ${value.toStringAsFixed(0)}'
                                        : '${currentData[dataIndex].day}일: ${value.toStringAsFixed(0)}';
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
                                      final unit = currentData[index].day;
                                      // 월간/일간 모드에 따라 라벨 조정
                                      if (_currentPeriod == ChartPeriod.monthly) {
                                        // 월간 모드는 모든 월 표시 (1~12월)
                                        return Text(
                                          '$unit',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        );
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
                                    if (value == 0 || value == maxY / 2 || value == maxY) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 4),
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
                                if (value == 0 || value == maxY / 2 || value == maxY) {
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
    
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
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
              toY: item.value,
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