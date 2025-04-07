import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/exceptions/failure.dart';
import '../../../data/models/my_channel/fantalk.dart';

abstract class FantalkRepository {
  /// 팬톡 목록 조회
  Future<Either<Failure, FanTalkResponse>> getFanTalks(String fantalkChannelId);

  /// 팬톡 등록
  Future<Either<Failure, Unit>> createFantalk(
    String fantalkChannelId, {
    required String content,
    int? trackId,
    MultipartFile? fantalkImage,
  });
}
