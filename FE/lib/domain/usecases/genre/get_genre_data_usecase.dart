import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/genre_remote_datasource.dart';
import 'package:ari/data/mappers/track_mapper.dart';
import 'package:ari/domain/entities/album.dart' as entity;
import 'package:ari/domain/entities/track.dart' as domain;
import 'package:ari/domain/entities/chart_item.dart';
import 'package:ari/core/utils/genre_utils.dart';
import 'package:dartz/dartz.dart';

class GetGenreDataUseCase {
  final GenreRemoteDataSource _genreDataSource;

  GetGenreDataUseCase(this._genreDataSource);

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

  Future<Either<Failure, List<domain.Track>>> getGenrePopularTracks(
    Genre genre,
  ) async {
    try {
      final tracks = await _genreDataSource.fetchGenrePopularTracks(genre);
      final entityTracks =
          tracks.map((t) => t.toDomainTrack()).toList(); // 데이터 모델 → 도메인 모델 변환
      return Right(entityTracks);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<entity.Album>>> getGenreNewAlbums(
    Genre genre,
  ) async {
    try {
      final albums = await _genreDataSource.fetchGenreNewAlbums(genre);
      final entityAlbums =
          albums.map((a) => entity.Album.fromDataModel(a)).toList(); // 변환
      return Right(entityAlbums);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<entity.Album>>> getGenrePopularAlbums(
    Genre genre,
  ) async {
    try {
      final albums = await _genreDataSource.fetchGenrePopularAlbums(genre);
      final entityAlbums =
          albums.map((a) => entity.Album.fromDataModel(a)).toList(); // 변환
      return Right(entityAlbums);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
