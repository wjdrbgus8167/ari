import 'package:ari/domain/entities/streaming_log.dart';

class StreamingLogModel {
  final String nickname;
  final String datetime;

  StreamingLogModel({
    required this.nickname,
    required this.datetime,
  });

  // JSON에서 모델 생성
  factory StreamingLogModel.fromJson(Map<String, dynamic> json) {
    return StreamingLogModel(
      nickname: json['nickname'] ?? '',
      datetime: json['datetime'] ?? '',
    );
  }

  // 모델을 엔티티로 변환
  StreamingLog toEntity() {
    return StreamingLog(
      nickname: nickname,
      datetime: datetime
    );
  }
}