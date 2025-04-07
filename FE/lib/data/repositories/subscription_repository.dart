import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/subscription/subscription_datasources.dart';
import 'package:ari/data/models/subscription/my_subscription_model.dart';
import 'package:ari/domain/repositories/subscription/subscription_repository.dart';
import 'package:dartz/dartz.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource dataSource;

  SubscriptionRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, MySubscriptionModel>> getMySubscription() async {
    try {
      final response = await dataSource.getMySubscription();

      // 응답 데이터 구조 확인
      if (response == null) {
        return Left(Failure(message: "Response data is null"));
      }
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}