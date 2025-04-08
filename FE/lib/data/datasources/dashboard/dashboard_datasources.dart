import 'package:ari/data/datasources/api_client.dart';
import 'package:ari/data/models/dashboard/dashboard_model.dart';
import 'package:ari/data/models/dashboard/track_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<TrackStatsList?> getTrackStatsList();
  Future<ArtistDashboardData?> getDashboardData();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({
    required this.apiClient,
  });
  
  @override
  Future<TrackStatsList?> getTrackStatsList() {
    return apiClient.request<TrackStatsList>(
      url: '/api/v1/mypages/tracks/list',
      method: 'GET',
      fromJson: (data) => TrackStatsList.fromJson(data), // 화살표 함수로 수정, return 추가
    );
  }

  @override
  Future<ArtistDashboardData?> getDashboardData() {
    return apiClient.request<ArtistDashboardData>(
      url: '/api/v1/mypages/dashboard',
      method: 'GET',
      fromJson: (data) => ArtistDashboardData.fromJson(data), // 화살표 함수로 수정, return 추가
    );
  }
}