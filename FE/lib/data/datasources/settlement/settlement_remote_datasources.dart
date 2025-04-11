import 'package:ari/data/datasources/api_client.dart';
import 'package:ari/data/models/settlement_model.dart';

abstract class SettlementRemoteDataSource {
  Future<Settlement?> getSettlementHistory(int year, int month, int day);
}

class SettlementRemoteDataSourceImpl implements SettlementRemoteDataSource {
  final ApiClient apiClient;

  SettlementRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<Settlement?> getSettlementHistory(int year, int month, int day) {
    return apiClient.request<Settlement>(
      url: '/api/v1/mypages/settlements/$year/$month/$day',
      method: 'GET',
      fromJson: (data) => Settlement.fromJson(data),
    );
  }
}