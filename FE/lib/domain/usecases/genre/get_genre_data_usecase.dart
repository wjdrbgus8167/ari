import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/genre_remote_datasource.dart';
import 'package:ari/data/models/album.dart';
import 'package:ari/data/models/track.dart';
import 'package:ari/domain/entities/chart_item.dart';
import 'package:ari/core/utils/genre_utils.dart';
import 'package:dartz/dartz.dart';

/// 장르별 데이터 조회 유스케이스
class GetGenreDataUseCase {
  final GenreRemoteDataSource _genreDataSource;

  GetGenreDataUseCase(this._genreDataSource);

  /// 장르별 인기 차트 조회 (30일 내 데이터)
  /// [genre] 장르 타입
  Future<Either<Failure, List<ChartItem>>> getGenreCharts(Genre genre) async {
    try {
      final charts = await _genreDataSource.fetchGenreCharts(genre);
      return Right(charts);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  /// 장르별 인기 트랙 조회 (7일 내 데이터)
  /// [genre] 장르 타입
  Future<Either<Failure, List<Track>>> getGenrePopularTracks(
    Genre genre,
  ) async {
    try {
      final tracks = await _genreDataSource.fetchGenrePopularTracks(genre);
      return Right(tracks);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  /// 장르별 신규 앨범 조회
  /// [genre] 장르 타입
  Future<Either<Failure, List<Album>>> getGenreNewAlbums(Genre genre) async {
    try {
      final albums = await _genreDataSource.fetchGenreNewAlbums(genre);
      return Right(albums);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  /// 장르별 인기 앨범 조회
  /// [genre] 장르 타입
  Future<Either<Failure, List<Album>>> getGenrePopularAlbums(
    Genre genre,
  ) async {
    try {
      final albums = await _genreDataSource.fetchGenrePopularAlbums(genre);
      return Right(albums);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
