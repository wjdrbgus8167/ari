import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/subscription/my_subscription_model.dart';
import 'package:ari/domain/repositories/subscription/subscription_repository.dart';
import 'package:dartz/dartz.dart';

/// 공지사항 댓글 목록 조회 유스케이스
class MySubscriptionUsecase {
  final SubscriptionRepository repository;

  MySubscriptionUsecase(this.repository);

  /// 유스케이스 실행: 댓글 목록 조회
  /// [noticeId]: 댓글을 조회할 공지사항 ID
  Future<Either<Failure, MySubscriptionModel>> call() {
    return repository.getMySubscription();
  }
}
