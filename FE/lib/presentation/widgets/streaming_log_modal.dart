import 'package:ari/domain/entities/streaming_log.dart';
import 'package:ari/presentation/viewmodels/streaming_log_viewmodel.dart';
import 'package:ari/providers/track/streaming_log_providers.dart';
// Provider 정의가 있는 파일을 임포트합니다
// 만약 StreamingLogViewmodel 파일에 Provider가 정의되어 있지 않다면
// Provider가 정의된 파일을 추가로 임포트해야 합니다
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StreamingHistoryModal extends ConsumerStatefulWidget {
  final int? albumId;
  final int? trackId;
  
  const StreamingHistoryModal({
    super.key,
    this.albumId,
    this.trackId,
  });

  @override
  ConsumerState<StreamingHistoryModal> createState() => _StreamingHistoryModalState();
}

class _StreamingHistoryModalState extends ConsumerState<StreamingHistoryModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    // 트랙 ID가 제공된 경우 해당 트랙의 스트리밍 로그를 로드
    Future.microtask(() {
      if (widget.trackId != null && widget.albumId != null) {
        ref.read(streamingLogViewModelProvider.notifier).loadAlbumDetail(widget.albumId!, widget.trackId!);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(streamingLogViewModelProvider);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, (1 - _animation.value) * 300),
          child: child,
        );
      },
      child: Container(
        width: 360,
        height: 360,
        padding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 40,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          color: Color(0xFF282828),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 320,
              height: 60,
              child: Text(
                '스트리밍 내역',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: _buildContent(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(StreamingState state) {
    print(state.errorMessage);
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(
          state.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state.logs.isEmpty) {
      return const Center(
        child: Text(
          '스트리밍 기록이 없습니다.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Pretendard',
          ),
        ),
      );
    }

    return _buildStreamingList(state.logs);
  }

  Widget _buildStreamingList(List<StreamingLog> logs) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        
        return Container(
          width: double.infinity,
          height: 40,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: ShapeDecoration(
            color: const Color(0xB2989595),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                log.nickname.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                log.datetime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 모달을 표시하는 확장 메서드
extension StreamingHistoryModalExtension on BuildContext {
  Future<void> showStreamingHistoryModal({int? albumId, int? trackId}) {
    return showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreamingHistoryModal(albumId: albumId, trackId: trackId),
    );
  }
}