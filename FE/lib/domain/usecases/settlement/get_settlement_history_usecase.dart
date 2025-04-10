import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/settlement_model.dart';
import 'package:ari/domain/repositories/settlement/settlement_repository.dart';
import 'package:dartz/dartz.dart';

/// 공지사항 댓글 목록 조회 유스케이스
class SettlementUsecase {
  final SettlementRepository repository;

  SettlementUsecase(this.repository);

  /// 유스케이스 실행: 댓글 목록 조회
  /// [noticeId]: 댓글을 조회할 공지사항 ID
  Future<Either<Failure, Settlement>> call(int month) {
    return repository.getSettlementHistory(month);
  }
}
