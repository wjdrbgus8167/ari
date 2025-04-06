import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/domain/entities/streaming_log.dart';
import 'package:dartz/dartz.dart';

abstract class StreamingRepository {
  /// 앨범 상세 정보를 가져오는 메서드
  Future<Either<Failure, List<StreamingLog>>> getStreamingLogByTrackId(int albumId, int trackId);
}