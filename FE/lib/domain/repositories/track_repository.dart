// domain/repositories/album_repository.dart

import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:dartz/dartz.dart';

abstract class TrackRepository {
  /// 앨범 상세 정보를 가져오는 메서드
  Future<Either<Failure, Track>> getTrackDetail(int albumId, int trackId);
}