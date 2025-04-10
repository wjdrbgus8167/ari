import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/dashboard/dashboard_datasources.dart';
import 'package:ari/data/models/dashboard/dashboard_model.dart';
import 'package:ari/data/models/dashboard/has_wallet_model.dart';
import 'package:ari/data/models/dashboard/track_stats_model.dart';
import 'package:ari/domain/repositories/dashboard/dashboard_repository.dart';
import 'package:dartz/dartz.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource dataSource;

  DashboardRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, TrackStatsList>> getTrackStatsList() async {
    try {
      final response = await dataSource.getTrackStatsList();

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

  @override
  Future<Either<Failure, ArtistDashboardData>> getDashboardData() async {
    try {
      final response = await dataSource.getDashboardData();

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

  @override
  Future<Either<Failure, HasWalletModel>> hasWallet() async {
    try {
      final response = await dataSource.hasWallet();

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