// 도메인 인터페이스 chart_repository.dart를 구현
// 실제 데이터 소스인 chart_remote_data_source.dart를 호출해서 api로 차트데이터를 받아옴
// baseurl 과 remotedatasource를 받아서 사용
import 'package:ari/domain/entities/chart_item.dart';
import 'package:ari/domain/repositories/chart_repository.dart';
import 'package:ari/data/datasources/chart_remote_data_source.dart';

class ChartRepositoryImpl implements IChartRepository {
  final ChartRemoteDataSource remoteDataSource;
  final String baseUrl;

  ChartRepositoryImpl({required this.remoteDataSource, required this.baseUrl});

  @override
  Future<List<ChartItem>> getCharts() async {
    return remoteDataSource.fetchCharts();
  }
}
