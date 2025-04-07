import 'package:ari/data/datasources/api_client.dart';
import 'package:ari/data/models/subscription/my_subscription_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<MySubscriptionModel?> getMySubscription();
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
}