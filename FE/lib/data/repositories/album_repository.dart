import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/datasources/album_remote_datasource.dart';
import 'package:ari/data/models/album_detail.dart';
import 'package:ari/data/models/album.dart' as data_model;
import 'package:ari/domain/entities/album.dart' as domain;
import 'package:ari/domain/repositories/album_repository.dart';
import 'package:dartz/dartz.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumDataSource dataSource;

  AlbumRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, domain.Album>> getAlbumDetail(int albumId) async {
    try {
      final response = await dataSource.getAlbumDetail(albumId);
      if (response.data == null) {
        return Left(Failure(message: "Response data is null"));
      }
      // 직접 캐스팅 대신, 매핑 함수를 사용하여 도메인 엔티티로 변환합니다.
      final domain.Album album = _mapAlbumDetailToDomain(
        response.data as AlbumDetailModel,
      );
      return Right(album);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  // AlbumDetailModel을 도메인 엔티티 Album으로 변환하는 매핑 함수
  domain.Album _mapAlbumDetailToDomain(AlbumDetailModel detail) {
    return domain.Album(
      albumId: detail.albumId,
      albumTitle: detail.albumTitle,
      artist: detail.artist,
      description: detail.description,
      albumLikeCount: detail.albumLikeCount,
      genre: detail.genre,
      commentCount: detail.commentCount,
      rating: detail.rating,
      createdAt: detail.createdAt,
      coverImageUrl: detail.coverImageUrl,
      comments: detail.comments, // 만약 타입이 다르다면 이 부분도 별도로 매핑 필요
      tracks: detail.tracks, // 마찬가지로 매핑 필요할 수 있음
    );
  }

  @override
  Future<Either<Failure, List<domain.Album>>> fetchPopularAlbums() async {
    try {
      final dataAlbums = await dataSource.fetchPopularAlbums();
      final domainAlbums =
          dataAlbums.map((album) => _mapDataAlbumToDomain(album)).toList();
      return Right(domainAlbums);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Album>>> fetchLatestAlbums() async {
    try {
      final dataAlbums = await dataSource.fetchLatestAlbums();
      final domainAlbums =
          dataAlbums.map((album) => _mapDataAlbumToDomain(album)).toList();
      return Right(domainAlbums);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  // 데이터 모델의 Album(data_model.Album)을 도메인 엔티티(domain.Album)로 변환하는 함수
  domain.Album _mapDataAlbumToDomain(data_model.Album album) {
    return domain.Album(
      albumId: album.id,
      albumTitle: album.title,
      artist: album.artist,
      description: "", // 기본값 빈 문자열 할당
      albumLikeCount: 0, // 기본값 0 할당
      genre: album.genre,
      commentCount: 0, // 기본값 0 할당
      rating: "0", // 기본값 "0" 할당
      createdAt: album.releaseDate.toString(),
      coverImageUrl: album.coverUrl,
      comments: [], // 기본값 빈 리스트 할당
      tracks: [], // 기본값 빈 리스트 할당
    );
  }
}
