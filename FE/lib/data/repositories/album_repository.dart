import 'package:ari/data/datasources/album_remote_datasource.dart';
import 'package:ari/data/models/album_detail.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/repositories/album_repository.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumDataSource dataSource;

  AlbumRepositoryImpl({required this.dataSource});

   @override
  Future<Album> getAlbumDetail(int albumId) async {
    final albumJson = await dataSource.getAlbumDetail(albumId);
    final albumModel = AlbumDetailModel.fromJson(albumJson);
    return albumModel;
  }
}