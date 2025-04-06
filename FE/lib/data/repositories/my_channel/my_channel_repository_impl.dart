import 'package:dartz/dartz.dart';
import '../../../core/exceptions/failure.dart';
import '../../../domain/repositories/my_channel/my_channel_repository.dart';
import '../../datasources/my_channel/my_channel_remote_datasource.dart';
import '../../models/my_channel/channel_info.dart';
import '../../models/my_channel/artist_album.dart';
import '../../models/my_channel/artist_notice.dart';
import '../../models/my_channel/fantalk.dart';
import '../../models/my_channel/public_playlist.dart';
import '../../models/my_channel/neighbor.dart';

class MyChannelRepositoryImpl implements MyChannelRepository {
  final MyChannelRemoteDataSource remoteDataSource;

  MyChannelRepositoryImpl({required this.remoteDataSource});

  /// API 호출 중 예외가 발생하면 Left(Failure) 반환
  /// 성공적으로 데이터를 받으면 Right(T) 반환
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

  @override
  Future<Either<Failure, ChannelInfo>> getChannelInfo(String memberId) {
    return _handleApiCall(() => remoteDataSource.getChannelInfo(memberId));
  }

  @override
  Future<Either<Failure, Unit>> followMember(String memberId) async {
    return _handleApiCall(() async {
      await remoteDataSource.followMember(memberId);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> unfollowMember(String memberId) async {
    return _handleApiCall(() async {
      await remoteDataSource.unfollowMember(memberId);
      return unit;
    });
  }

  @override
  Future<Either<Failure, List<ArtistAlbum>>> getArtistAlbums(String memberId) {
    return _handleApiCall(() => remoteDataSource.getArtistAlbums(memberId));
  }

  @override
  Future<Either<Failure, ArtistNoticeResponse>> getArtistNotices(
    String memberId,
  ) {
    return _handleApiCall(() => remoteDataSource.getArtistNotices(memberId));
  }

  @override
  Future<Either<Failure, FanTalkResponse>> getFanTalks(
    String fantalkChannelId,
  ) {
    return _handleApiCall(() => remoteDataSource.getFanTalks(fantalkChannelId));
  }

  @override
  Future<Either<Failure, PublicPlaylistResponse>> getPublicPlaylists(
    String memberId,
  ) {
    return _handleApiCall(() => remoteDataSource.getPublicPlaylists(memberId));
  }

  @override
  Future<Either<Failure, FollowerResponse>> getFollowers(String memberId) {
    return _handleApiCall(() => remoteDataSource.getFollowers(memberId));
  }

  @override
  Future<Either<Failure, FollowingResponse>> getFollowings(String memberId) {
    return _handleApiCall(() => remoteDataSource.getFollowings(memberId));
  }
}
