import 'package:ari/domain/entities/streaming_log.dart';

abstract class StreamingRepository {
  /// 앨범 상세 정보를 가져오는 메서드
  Future<StreamingLog> getStreamingLog(int streamingId);
}