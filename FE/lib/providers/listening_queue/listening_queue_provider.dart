import 'package:ari/providers/global_providers.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/domain/entities/track.dart' as domain;
import 'package:ari/data/datasources/local/local_listening_queue_datasource.dart';
import 'package:ari/presentation/viewmodels/listening_queue_viewmodel.dart';

class ListeningQueueNotifier extends StateNotifier<List<domain.Track>> {
  ListeningQueueNotifier({required this.userId}) : super([]) {
    _loadQueue();
  }

  final String userId;

  /// 사용자별 재생목록을 로드합니다.
  Future<void> _loadQueue() async {
    // local_listening_queue_datasource.dart의 loadListeningQueue는 List<data.Track>를 반환합니다.
    final dataTracks = await loadListeningQueue(userId);
    // data 모델을 도메인 엔티티로 변환합니다.
    final domainTracks =
        dataTracks
            .map((dataTrack) => domain.Track.fromDataModel(dataTrack))
            .toList();
    state = domainTracks;
  }

  /// 재생목록에 새 트랙을 추가합니다.
  Future<void> addTrack(domain.Track track) async {
    // 도메인 Track을 data Track으로 변환하여 저장합니다.
    final dataTrack = track.toDataModel();
    await addTrackToListeningQueue(userId, dataTrack);
    await _loadQueue();
  }

  /// 재생목록에서 특정 트랙을 삭제합니다.
  Future<void> removeTrack(domain.Track track) async {
    await removeTrackFromListeningQueue(userId, track.trackId);
    await _loadQueue();
  }

  /// 재생목록의 순서를 변경한 후, 새로운 순서대로 저장합니다.
  Future<void> updateQueueOrder(List<domain.Track> newOrder) async {
    // 도메인 Track 리스트를 data Track 리스트로 변환합니다.
    final dataTracks = newOrder.map((track) => track.toDataModel()).toList();
    await updateListeningQueueOrder(userId, dataTracks);
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
