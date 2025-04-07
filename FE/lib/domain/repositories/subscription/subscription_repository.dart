import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/subscription/my_subscription_model.dart';
import 'package:dartz/dartz.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, MySubscriptionModel>> getMySubscription();
}