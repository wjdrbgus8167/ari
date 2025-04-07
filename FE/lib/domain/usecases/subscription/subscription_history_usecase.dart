import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/subscription/artist_subscription_models.dart';
import 'package:ari/data/models/subscription/regular_subscription_models.dart';
import 'package:ari/domain/repositories/subscription/subscription_repository.dart';
import 'package:dartz/dartz.dart';

class SubscriptionCycleUsecase {
  final SubscriptionRepository repository;

  SubscriptionCycleUsecase(this.repository);

  
  Future<Either<Failure, List<SubscriptionCycle>>> call() {
    return repository.getRegularSubscriptionCycle();
  }
}

class RegularSubscriptionDetailUsecase {
  final SubscriptionRepository repository;

  RegularSubscriptionDetailUsecase(this.repository);

  
  Future<Either<Failure, RegularSubscriptionDetail>> call(int subscriptionId) {
    return repository.getRegularSubscriptionDetail(subscriptionId);
  }
}

class ArtistSubscriptionHistoryUsecase {
  final SubscriptionRepository repository;

  ArtistSubscriptionHistoryUsecase(this.repository);

  
  Future<Either<Failure, ArtistsResponse>> call() {
    return repository.getArtistSubscriptionHistory();
  }
}

class ArtistSubscriptionDetailUsecase {
  final SubscriptionRepository repository;

  ArtistSubscriptionDetailUsecase(this.repository);

  
  Future<Either<Failure, ArtistDetail>> call(int artistId) {
    return repository.getArtistSubscriptionDetail(artistId);
  }
}