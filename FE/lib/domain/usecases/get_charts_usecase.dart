//차트조회를 수행하는 단위작업
//ui나 다른 계층에서 이 usecase만 호출하면 됨 -> 비지니스 로직 중앙집중화, 테스트 용이함

import '../entities/chart_item.dart';
import '../repositories/chart_repository.dart';

class GetChartsUseCase {
  final IChartRepository repository;

  GetChartsUseCase(this.repository);

  Future<List<ChartItem>> execute() async {
    return repository.getCharts();
  }
}
