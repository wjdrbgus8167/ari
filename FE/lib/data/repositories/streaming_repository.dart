import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/streaming_remote_datasource.dart';
import 'package:ari/data/models/streaming_log_model';
import 'package:ari/domain/entities/streaming_log.dart';
import 'package:ari/domain/repositories/streaming_repository.dart';
import 'package:dartz/dartz.dart';

class StreamingRepositoryImpl implements StreamingRepository {
  final StreamingDataSource dataSource;

  StreamingRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<StreamingLog>>> getStreamingLogByTrackId(int albumId, int trackId) async {
    try {
      final response = await dataSource.getStreamingLogByTrackId(albumId, trackId);
      
      // 응답 데이터가 streamings 키를 가진 맵으로 가정
      final streamingsJson = (response.data as Map<String, dynamic>)['streamings'] as List<dynamic>;
      
      // StreamingLog 엔티티 리스트로 변환
      final streamingLogs = streamingsJson
          .map((item) => StreamingLogModel.fromJson(item).toEntity())
          .toList();
          
      return Right(streamingLogs);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}