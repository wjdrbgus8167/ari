import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/track/track_remote_datasource.dart';
import 'package:ari/data/models/track_detail.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/repositories/track/track_detail_repository.dart';
import 'package:dartz/dartz.dart';

class TrackRepositoryImpl implements TrackRepository {
  final TrackDataSource dataSource;

  TrackRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Track>> getTrackDetail(int albumId, int trackId) async {
    try {
      final response = await dataSource.getTrackDetail(albumId, trackId);

      // 응답 데이터 구조 확인
      if (response.data == null) {
        return Left(Failure(message: "Response data is null"));
      }
      final result = response.data as TrackDetailModel;
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}