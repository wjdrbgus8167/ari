import 'package:ari/domain/entities/track.dart';

class PlaylistTrackItem {
  final Track track;
  final int trackOrder;

  PlaylistTrackItem({required this.track, required this.trackOrder});
  factory PlaylistTrackItem.fromJson(Map<String, dynamic> json) {
    return PlaylistTrackItem(
      track: Track.fromJson(json['track'] as Map<String, dynamic>),
      trackOrder: json['trackOrder'] as int,
    );
  }
}
