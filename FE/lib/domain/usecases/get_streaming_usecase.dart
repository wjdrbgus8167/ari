import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/domain/entities/streaming_log.dart';
import 'package:ari/domain/repositories/streaming_repository.dart';
import 'package:dartz/dartz.dart';

class GetStreamingLogByTrackId {
  final StreamingRepository repository;

  GetStreamingLogByTrackId(this.repository);

  /// 앨범 상세 정보를 가져오는 유스케이스
  /// [albumId]: 조회할 앨범의 ID
  Future<Either<Failure, List<StreamingLog>>> execute(int albumId, int trackId) async {
    return await repository.getStreamingLogByTrackId(albumId, trackId);
  }
}