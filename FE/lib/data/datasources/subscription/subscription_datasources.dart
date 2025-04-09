import 'dart:convert';

import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/api_client.dart';
import 'package:ari/data/models/subscription/artist_subscription_models.dart';
import 'package:ari/data/models/subscription/my_subscription_model.dart';
import 'package:ari/data/models/subscription/regular_subscription_models.dart';
import 'package:dartz/dartz.dart';


abstract class SubscriptionRemoteDataSource {
  Future<MySubscriptionModel?> getMySubscription();

  Future<ArtistDetail?> getArtistSubscriptionDetail(int artistId);

  Future<ArtistsResponse?> getArtistSubscriptionHistory();

  Future<RegularSubscriptionDetail?> getRegularSubscriptionDetail(int subscriptionId);

  Future<List<SubscriptionCycle>> getRegularSubscriptionCycle();
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  
  final ApiClient apiClient;

  SubscriptionRemoteDataSourceImpl({
    required this.apiClient,
  });
  
  @override
  Future<MySubscriptionModel?> getMySubscription() {
    return apiClient.request<MySubscriptionModel>(
      url: '/api/v1/mypages/subscriptions/list',
      method: 'GET',
      fromJson: (data) => MySubscriptionModel.fromJson(data), // 화살표 함수로 수정, return 추가
    );
  }
  @override
  Future<ArtistDetail?> getArtistSubscriptionDetail(int artistId) {
    return apiClient.request<ArtistDetail>(
      url: '/api/v1/mypages/subscriptions/artists/$artistId/detail',
      method: 'GET',
      fromJson: (data) => ArtistDetail.fromJson(data),
    );
  }
  @override
  Future<ArtistsResponse?> getArtistSubscriptionHistory() {
    return apiClient.request<ArtistsResponse>(
      url: '/api/v1/mypages/subscriptions/artists/list',
      method: 'GET',
      fromJson: (data) => ArtistsResponse.fromJson(data),
    );
  }
  @override
  Future<RegularSubscriptionDetail?> getRegularSubscriptionDetail(int subscriptionId) {
    return apiClient.request<RegularSubscriptionDetail>(
      url: '/api/v1/mypages/subscriptions/regular/detail/$subscriptionId',
      method: 'GET',
      fromJson: (data) => RegularSubscriptionDetail.fromJson(data),
    );
  }
  @override
  Future<List<SubscriptionCycle>> getRegularSubscriptionCycle() {
    print("이거 요청함");
    return apiClient.request<List<SubscriptionCycle>>(
      url: '/api/v1/mypages/subscriptions/regular/list',
      method: 'GET',
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => SubscriptionCycle.fromJson(item)).toList();
        } else if (data is Map<String, dynamic>) {
          // 데이터가 객체로 왔을 경우 리스트로 변환
          final cycles = data['cycles'] ?? data['data'] ?? [data];
          if (cycles is List) {
            return cycles.map((item) => SubscriptionCycle.fromJson(item)).toList();
          }
        }
        return []; // 기본값으로 빈 리스트 반환
      },
    );
  }
}