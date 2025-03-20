import 'package:ari/data/datasources/track_remote_datasource.dart';
import 'package:ari/data/models/track_detail.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/repositories/track_repository.dart';

class TrackRepositoryImpl implements TrackRepository {
  final TrackDataSource dataSource;

  TrackRepositoryImpl({required this.dataSource});

   @override
  Future<TrackDetailModel> getTrackDetail(int trackId) async {
    final trackJson = await dataSource.getTrackDetail(trackId);
    final trackModel = TrackDetailModel.fromJson(trackJson);
    print("레포지토리에서 발생: "+trackModel.albumTitle);
    return trackModel;
  }
}