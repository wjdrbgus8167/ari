import 'package:ari/domain/entities/track.dart';

class PlaylistTrackItem {
  final Track track;
  final int trackOrder;

  PlaylistTrackItem({required this.track, required this.trackOrder});
}
