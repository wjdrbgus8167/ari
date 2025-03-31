import 'package:ari/providers/global_providers.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/data/datasources/local/local_listening_queue_datasource.dart';
import 'package:ari/presentation/viewmodels/listening_queue_viewmodel.dart';

class ListeningQueueNotifier extends StateNotifier<List<Track>> {
  ListeningQueueNotifier({required this.userId}) : super([]) {
    _loadQueue();
  }

  final String userId;

  /// 사용자별 재생목록을 로드합니다.
  Future<void> _loadQueue() async {
    final tracks = await loadListeningQueue(userId);
    state = tracks;
  }

  /// 재생목록에 새 트랙을 추가합니다.
  Future<void> addTrack(Track track) async {
    await addTrackToListeningQueue(userId, track);
    await _loadQueue();
  }

  /// 재생목록에서 특정 트랙을 삭제합니다.
  Future<void> removeTrack(Track track) async {
    await removeTrackFromListeningQueue(userId, track.trackId);
    await _loadQueue();
  }

  /// 재생목록의 순서를 변경한 후, 새로운 순서대로 저장합니다.
  Future<void> updateQueueOrder(List<Track> newOrder) async {
    await updateListeningQueueOrder(userId, newOrder);
    state = newOrder;
  }
}

final listeningQueueProvider =
    StateNotifierProvider<ListeningQueueViewModel, ListeningQueueState>((ref) {
      final userId = ref.watch(authUserIdProvider);
      final playlistRepository = ref.watch(playlistRepositoryProvider);
      return ListeningQueueViewModel(
        userId: userId,
        playlistRepository: playlistRepository,
      );
    });
