import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/exceptions/failure.dart';
import '../../../domain/repositories/my_channel/fantalk_repository.dart';
import '../../datasources/my_channel/fantalk_remote_datasource.dart';
import '../../models/my_channel/fantalk.dart';

class FantalkRepositoryImpl implements FantalkRepository {
  final FantalkRemoteDataSource remoteDataSource;

  FantalkRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _handleApiCall<T>(
    Future<T> Function() apiCall,
  ) async {
    try {
      final result = await apiCall();
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  /// 팬톡 목록 조회
  /// [fantalkChannelId] : 팬톡 채널 ID
  @override
  Future<Either<Failure, FanTalkResponse>> getFanTalks(
    String fantalkChannelId,
  ) {
    return _handleApiCall(() => remoteDataSource.getFanTalks(fantalkChannelId));
  }

  /// 팬톡 등록
  @override
  Future<Either<Failure, Unit>> createFantalk(
    String fantalkChannelId, {
    required String content,
    int? trackId,
    MultipartFile? fantalkImage,
  }) {
    return _handleApiCall(() async {
      await remoteDataSource.createFantalk(
        fantalkChannelId,
        content: content,
        trackId: trackId,
        fantalkImage: fantalkImage,
      );
      return unit;
    });
  }
}
