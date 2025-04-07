import 'package:ari/data/models/track.dart' as data;
import 'package:ari/domain/entities/track.dart' as domain;
import 'package:ari/data/mappers/track_mapper.dart';

domain.Track safeToDomainTrack(dynamic track) {
  if (track is data.Track) {
    return track.toDomainTrack();
  } else if (track is domain.Track) {
    return track;
  } else {
    throw Exception(
      '❌ e.track 타입이 data.Track도 domain.Track도 아닙니다: ${track.runtimeType}',
    );
  }
}
