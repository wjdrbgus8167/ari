import 'package:ari/core/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

/// 앨범 평점 기능을 위한 도메인 Repository 인터페이스
abstract class AlbumRatingRepository {
  /// [albumId] 앨범에 [rating] 평점을 등록하는 함수
  Future<Either<Failure, void>> rateAlbum(int albumId, double rating);
}
