import 'package:ari/data/datasources/api_client.dart';
import 'package:ari/data/models/settlement_model.dart';

abstract class SettlementRemoteDataSource {
  Future<Settlement?> getSettlementHistory(int month);
}

class SettlementRemoteDataSourceImpl implements SettlementRemoteDataSource {
  final ApiClient apiClient;

  SettlementRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<Settlement?> getSettlementHistory(int month) {
    return apiClient.request<Settlement>(
      url: '/api/v1/mypages/settlement/$month',
      method: 'GET',
      fromJson: (data) => Settlement.fromJson(data),
    );
  }
}