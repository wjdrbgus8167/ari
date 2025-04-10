import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/settlement_model.dart';
import 'package:dartz/dartz.dart';

abstract class SettlementRepository {
  Future<Either<Failure, Settlement>> getSettlementHistory(int month);
}