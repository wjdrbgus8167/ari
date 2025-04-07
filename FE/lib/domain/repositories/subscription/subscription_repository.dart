import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/subscription/artist_subscription_models.dart';
import 'package:ari/data/models/subscription/my_subscription_model.dart';
import 'package:ari/data/models/subscription/regular_subscription_models.dart';
import 'package:dartz/dartz.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, MySubscriptionModel>> getMySubscription();

  Future<Either<Failure, List<SubscriptionCycle>>> getRegularSubscriptionCycle();

  Future<Either<Failure, RegularSubscriptionDetail>> getRegularSubscriptionDetail(int subscriptionId);

  Future<Either<Failure, ArtistsResponse>> getArtistSubscriptionHistory();

  Future<Either<Failure, ArtistDetail>> getArtistSubscriptionDetail(int artistId);
}