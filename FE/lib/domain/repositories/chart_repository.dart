// 도메인 계층에서 차트 데이터를 가져오기 위한 추상 인터페이스 정의
// 실제 데이터소스인 api,캐시,db에 의존하지 않고
//비지니스 로직에선느 인터페이스만 사용해서 유연하게 구현체 교체 가능
//보통 인터페이스임을 명시하기 위해 앞에 'I'를 붙임

import '../entities/chart_item.dart';

abstract class IChartRepository {
  Future<List<ChartItem>> getCharts();
}
