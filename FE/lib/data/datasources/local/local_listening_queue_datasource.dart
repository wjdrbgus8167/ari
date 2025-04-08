import 'package:hive/hive.dart';
import 'package:ari/data/models/track.dart';

/// 사용자별 재생목록을 저장하는 Box를 엽니다.
Future<Box<Track>> openListeningQueueBox(String userId) async {
  final boxName = 'listening_queue_$userId';

  // // ❗ 기존 박스를 삭제(개발용 코드)
  // if (await Hive.boxExists(boxName)) {
  //   print('[DEBUG] 기존 박스 삭제: $boxName');
  //   await Hive.deleteBoxFromDisk(boxName);
  // }

  // // Hive 전체 초기화 (개발용 코드)
  // await Hive.close();
  // await Hive.deleteBoxFromDisk('listening_queue_$userId');
  // await Hive.openBox<Track>('listening_queue_$userId');

  // ✅ 새로운 박스 열기
  return await Hive.openBox<Track>(boxName);
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

  for (var track in tracks) {
    await box.add(track.clone()); // ✅ clone으로 새 인스턴스 저장
  }
}

/// 재생목록에 새로운 트랙을 추가하는 함수
/// (중복된 트랙도 쌓이도록 하며, 외부에서 재생 시 새 트랙이 최상단에 오도록 합니다.)
Future<void> addTrackToListeningQueue(String userId, Track track) async {
  final box = await openListeningQueueBox(userId);
  print('[DEBUG] addTrackToListeningQueue: 추가 전 재생목록 길이: ${box.values.length}');

  final currentTracks = box.values.toList();
  final newTracks = [track.clone(), ...currentTracks]; // ✅ 새 인스턴스로 삽입

  await box.clear();
  for (var t in newTracks) {
    await box.add(t.clone()); // ✅ 각각 clone해서 안전하게 저장
  }

  print('[DEBUG] addTrackToListeningQueue: 추가 후 재생목록 길이: ${box.values.length}');
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
