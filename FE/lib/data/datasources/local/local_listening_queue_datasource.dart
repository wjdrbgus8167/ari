import 'package:hive/hive.dart';
import 'package:ari/data/models/track.dart';

/// 사용자별 재생목록을 저장하는 Box를 엽니다.
Future<Box<Track>> openListeningQueueBox(String userId) async {
  return await Hive.openBox<Track>('listening_queue_$userId');
}

/// 사용자별 재생목록을 불러오는 함수
Future<List<Track>> loadListeningQueue(String userId) async {
  final box = await openListeningQueueBox(userId);
  return box.values.toList();
}

/// 사용자별 재생목록 전체를 저장하는 함수
/// 기존의 박스 내용을 모두 지우고, 새로운 재생목록 순서대로 저장합니다.
Future<void> saveListeningQueue(String userId, List<Track> tracks) async {
  final box = await openListeningQueueBox(userId);
  await box.clear();
  // 순서를 유지하면서 저장합니다.
  for (var track in tracks) {
    await box.add(track);
  }
}

/// 재생목록에 새로운 트랙을 추가하는 함수
/// 만약 마지막 트랙과 동일하면 중복 추가하지 않고, 다른 곡 후 다시 추가되면 중복 저장되도록 함.
Future<void> addTrackToListeningQueue(String userId, Track track) async {
  final box = await openListeningQueueBox(userId);
  if (box.values.isNotEmpty) {
    final lastTrack = box.values.last;
    // 마지막 트랙과 동일한 경우, 추가하지 않음 (연속 재생 시 중복 방지)
    if (lastTrack.id == track.id) {
      return;
    }
  }
  await box.add(track);
}

/// 재생목록에서 특정 트랙을 삭제하는 함수
Future<void> removeTrackFromListeningQueue(String userId, int trackId) async {
  final box = await openListeningQueueBox(userId);
  // 박스 내의 key를 순회하며, 해당 트랙 id와 일치하는 항목을 찾아 삭제합니다.
  final keyToRemove = box.keys.firstWhere((key) {
    final storedTrack = box.get(key) as Track;
    return storedTrack.id == trackId;
  }, orElse: () => null);
  if (keyToRemove != null) {
    await box.delete(keyToRemove);
  }
}

/// 재생목록의 순서를 변경한 후, 변경된 순서대로 전체 재생목록을 저장하는 함수
Future<void> updateListeningQueueOrder(
  String userId,
  List<Track> newOrder,
) async {
  // 전체 재생목록을 새 순서대로 저장합니다.
  await saveListeningQueue(userId, newOrder);
}
