import 'package:ari/data/datasources/album_remote_datasource.dart';
import 'package:ari/data/models/album_detail.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/repositories/album_repository.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumDataSource dataSource;

  AlbumRepositoryImpl({required this.dataSource});

   @override
  Future<Album> getAlbumDetail(int albumId) async {
    print("레포1");
    final albumJson = await dataSource.getAlbumDetail(albumId);
    print("레포2");
    final albumModel = AlbumDetailModel.fromJson(albumJson);
    print("레포3");
    return albumModel;
  }
}