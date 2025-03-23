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

      // 응답 데이터 구조 확인
      if (response.data == null) {
        return Left(Failure(message: "Response data is null"));
      }
      // 안전한 타입 체크 및 변환
      if (response.data is Map<String, dynamic>) {
        final dataMap = response.data as Map<String, dynamic>;
        
        if (dataMap.containsKey('streamings')) {
          final streamingsData = dataMap['streamings'];
          
          if (streamingsData is List) {
            // StreamingLog 엔티티 리스트로 변환
            final streamingLogs = streamingsData
                .map((item) => StreamingLogModel.fromJson(item).toEntity())
                .toList();
                
            return Right(streamingLogs);
          } else {
            return Left(Failure(message: "Streamings is not a list"));
          }
        } else {
          return Left(Failure(message: "No streamings found in response"));
        }
      } else {
        return Left(Failure(message: "Response data is not a map: ${response.data.runtimeType}"));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}