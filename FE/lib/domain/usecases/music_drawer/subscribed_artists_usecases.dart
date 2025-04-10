import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/subscription/artist_subscription_models.dart';
import 'package:ari/domain/repositories/music_drawer/subscribed_artists_repository.dart';
import 'package:ari/data/models/music_drawer/subscribed_artist_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// 구독 중인 아티스트 목록 조회 유스케이스
class GetSubscribedArtistsUseCase {
  final SubscribedArtistsRepository _repository;

  GetSubscribedArtistsUseCase(this._repository);

  Future<Either<Failure, ArtistsResponse>> execute() {
    return _repository.getSubscribedArtists();
  }
}
