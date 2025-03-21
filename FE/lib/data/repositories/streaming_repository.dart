import 'package:ari/data/datasources/streaming_remote_datasource.dart';
import 'package:ari/data/models/streaming_log_model';
import 'package:ari/domain/entities/streaming_log.dart';
import 'package:ari/domain/repositories/streaming_repository.dart';

class StreamingRepositoryImpl implements StreamingRepository {
  final StreamingDataSource dataSource;

  StreamingRepositoryImpl({required this.dataSource});

  Future<List<StreamingLog>> getStreamingLogByTrackId(int trackId) async {
    final response = await dataSource.getStreamingLogByTrackId(trackId);
  
    // API 응답이 data.streamings 형태인 경우
    final streamingsJson = response['data']['streamings'] as List<dynamic>;
    
    // StreamingLogModel 리스트로 변환 후 엔티티 리스트로 변환
    return streamingsJson
      .map((item) => StreamingLogModel.fromJson(item as Map<String, dynamic>).toEntity())
      .toList();
  }
}