import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/settlement/settlement_remote_datasources.dart';
import 'package:ari/data/models/settlement_model.dart';
import 'package:ari/domain/repositories/settlement/settlement_repository.dart';
import 'package:dartz/dartz.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  final SettlementRemoteDataSource dataSource;

  SettlementRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Settlement>> getSettlementHistory(int month) async {
    try {
      final response = await dataSource.getSettlementHistory(month);

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