import 'package:ari/domain/entities/track.dart';

class ListeningQueueItem {
  final Track track;
  final String uniqueId;

  ListeningQueueItem({required this.track})
    : uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

  // 동일한 중복 트랙을 uniqueid로 비교하게 함
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListeningQueueItem && other.uniqueId == uniqueId;

  @override
  int get hashCode => uniqueId.hashCode;
}
