import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/exceptions/failure.dart';
import '../../../data/models/my_channel/fantalk.dart';
import '../../../domain/repositories/my_channel/fantalk_repository.dart';

class GetFanTalksUseCase {
  final FantalkRepository repository;

  GetFanTalksUseCase(this.repository);

  /// 팬톡 목록 조회 실행
  /// [fantalkChannelId] : 팬톡 채널 ID
  Future<Either<Failure, FanTalkResponse>> execute(String fantalkChannelId) {
    return repository.getFanTalks(fantalkChannelId);
  }
}

/// 팬톡 생성 유스케이스
class CreateFantalkUseCase {
  final FantalkRepository repository;

  CreateFantalkUseCase(this.repository);

  /// 팬톡 등록 실행
  Future<Either<Failure, Unit>> execute(
    String fantalkChannelId, {
    required String content,
    int? trackId,
    MultipartFile? fantalkImage,
  }) {
    return repository.createFantalk(
      fantalkChannelId,
      content: content,
      trackId: trackId,
      fantalkImage: fantalkImage,
    );
  }
}
