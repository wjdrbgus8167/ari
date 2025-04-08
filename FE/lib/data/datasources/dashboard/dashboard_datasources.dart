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


final String mockDataJson = '''
{
  "walletAddress": "0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9",
  "subscriberCount": 1245,
  "totalStreamingCount": 28456,
  "todayStreamingCount": 732,
  "streamingDiff": 45,
  "todayNewSubscriberCount": 18,
  "newSubscriberDiff": 3,
  "todaySettlement": 35.8,
  "settlementDiff": 5.2,
  "todayNewSubscribeCount": 22,
  "albums": [
    {
      "albumTitle": "Midnight Blues",
      "coverImageUrl": "https://example.com/covers/midnight_blues.jpg",
      "trackCount": 10
    },
    {
      "albumTitle": "Dawn Chorus",
      "coverImageUrl": "https://example.com/covers/dawn_chorus.jpg",
      "trackCount": 8
    },
    {
      "albumTitle": "Electric Dreams",
      "coverImageUrl": "https://example.com/covers/electric_dreams.jpg",
      "trackCount": 12
    }
  ],
  "dailySubscriberCounts": [
    {
      "date": "25.04.01",
      "subscriberCount": 1180
    },
    {
      "date": "25.04.02",
      "subscriberCount": 1195
    },
    {
      "date": "25.04.03",
      "subscriberCount": 1205
    },
    {
      "date": "25.04.04",
      "subscriberCount": 1210
    },
    {
      "date": "25.04.05",
      "subscriberCount": 1218
    },
    {
      "date": "25.04.06",
      "subscriberCount": 1227
    },
    {
      "date": "25.04.07",
      "subscriberCount": 1235
    },
    {
      "date": "25.04.08",
      "subscriberCount": 1245
    }
  ],
  "dailySettlement": [
    {
      "date": "25.04.01",
      "settlement": 28.4
    },
    {
      "date": "25.04.02",
      "settlement": 30.2
    },
    {
      "date": "25.04.03",
      "settlement": 29.5
    },
    {
      "date": "25.04.04",
      "settlement": 31.8
    },
    {
      "date": "25.04.05",
      "settlement": 27.9
    },
    {
      "date": "25.04.06",
      "settlement": 30.6
    },
    {
      "date": "25.04.07",
      "settlement": 32.5
    },
    {
      "date": "25.04.08",
      "settlement": 35.8
    }
  ]
}
''';
