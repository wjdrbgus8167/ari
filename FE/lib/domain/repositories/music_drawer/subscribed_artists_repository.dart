import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/music_drawer/subscribed_artist_model.dart';
import 'package:ari/data/models/subscription/artist_subscription_models.dart';
import 'package:dartz/dartz.dart';

abstract class SubscribedArtistsRepository {
  /// 구독 중인 아티스트 목록 조회
  Future<Either<Failure, ArtistsResponse>> getSubscribedArtists();
}
