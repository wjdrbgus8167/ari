import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/repositories/track_repository.dart';
import 'package:dartz/dartz.dart';

class GetTrackDetail {
  final TrackRepository repository;

  GetTrackDetail(this.repository);

  /// 앨범 상세 정보를 가져오는 유스케이스
  /// [albumId]: 조회할 앨범의 ID
  Future<Either<Failure, Track>> execute(int albumId, int trackId) async {
    return await repository.getTrackDetail(albumId, trackId);
  }
}