import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/subscription/subscription_datasources.dart';
import 'package:ari/data/models/subscription/artist_subscription_models.dart';
import 'package:ari/data/models/subscription/my_subscription_model.dart';
import 'package:ari/data/models/subscription/regular_subscription_models.dart';
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
      return Left(Failure(message: "error"));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionCycle>>> getRegularSubscriptionCycle() async {
    try {
      final response = await dataSource.getRegularSubscriptionCycle();

      // 응답 데이터 구조 확인
      if (response == null) {
        return Left(Failure(message: "Response data is null"));
      }
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: "error"));
    }
  }

  @override
  Future<Either<Failure, RegularSubscriptionDetail>> getRegularSubscriptionDetail(int subscriptionId) async {
    try {
      final response = await dataSource.getRegularSubscriptionDetail(subscriptionId);

      // 응답 데이터 구조 확인
      if (response == null) {
        return Left(Failure(message: "Response data is null"));
      }
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: "error"));
    }
  }

  @override
  Future<Either<Failure, ArtistsResponse>> getArtistSubscriptionHistory() async {
    try {
      final response = await dataSource.getArtistSubscriptionHistory();

      // 응답 데이터 구조 확인
      if (response == null) {
        return Left(Failure(message: "Response data is null"));
      }
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: "error"));
    }
  }

  @override
  Future<Either<Failure, ArtistDetail>> getArtistSubscriptionDetail(int artistId) async {
    try {
      final response = await dataSource.getArtistSubscriptionDetail(artistId);

      // 응답 데이터 구조 확인
      if (response == null) {
        return Left(Failure(message: "Response data is null"));
      }
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: "error"));
    }
  }
}