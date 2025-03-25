import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/streaming_remote_datasource.dart';
import 'package:ari/data/models/streaming_log_model.dart';
import 'package:ari/domain/entities/streaming_log.dart';
import 'package:ari/domain/repositories/streaming_repository.dart';
import 'package:dartz/dartz.dart';

class StreamingRepositoryImpl implements StreamingRepository {
  final StreamingDataSource dataSource;

  StreamingRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<StreamingLog>>> getStreamingLogByTrackId(
    int albumId,
    int trackId,
  ) async {
    try {
      final response = await dataSource.getStreamingLogByTrackId(
        albumId,
        trackId,
      );

      // 응답 데이터 구조 확인
      if (response.data == null) {
        return Left(Failure(message: "Response data is null"));
      }
      final responseData = response.data as List<StreamingLogModel>;
      final result = responseData.map((item) => item.toEntity()).toList();

      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
