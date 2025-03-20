// domain/repositories/album_repository.dart

import 'package:ari/data/models/track_detail.dart';
import 'package:ari/domain/entities/track.dart';

abstract class TrackRepository {
  /// 앨범 상세 정보를 가져오는 메서드
  Future<TrackDetailModel> getTrackDetail(int trackId);
}