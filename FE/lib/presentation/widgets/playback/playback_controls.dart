import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/providers/playback/playback_progress_provider.dart';
import 'package:ari/core/services/audio_service.dart';

class PlaybackControls extends ConsumerStatefulWidget {
  final VoidCallback onToggle; // 기존 콜백 (필요시 제거 가능)
  const PlaybackControls({Key? key, required this.onToggle}) : super(key: key);

  @override
  _PlaybackControlsState createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends ConsumerState<PlaybackControls> {
  double _sliderValue = 0.0;
  bool _isUserInteracting = false;

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);
    final isPlaying = playbackState.isPlaying;
    final positionAsync = ref.watch(playbackPositionProvider);
    final durationAsync = ref.watch(playbackDurationProvider);

    Duration position = Duration.zero;
    Duration duration = Duration.zero;
    if (positionAsync.asData != null) {
      position = positionAsync.asData!.value;
    }
    if (durationAsync.asData != null && durationAsync.asData!.value != null) {
      duration = durationAsync.asData!.value!;
    }

    // 사용자가 슬라이더를 조작하지 않을 때, 자동 업데이트
    if (!_isUserInteracting && duration.inMilliseconds > 0) {
      _sliderValue = position.inMilliseconds / duration.inMilliseconds;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      color: Colors.black.withOpacity(0.6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _sliderValue.clamp(0.0, 1.0),
            onChanged: (value) {
              setState(() {
                _isUserInteracting = true;
                _sliderValue = value;
              });
            },
            onChangeEnd: (value) {
              if (duration.inMilliseconds > 0) {
                final newPosition = Duration(
                  milliseconds: (duration.inMilliseconds * value).toInt(),
                );
                ref.read(audioServiceProvider).seekTo(newPosition);
              }
              setState(() {
                _isUserInteracting = false;
              });
            },
            activeColor: Colors.white,
            inactiveColor: Colors.white38,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shuffle,
                  color: Colors.white70,
                  size: 28,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () {},
              ),
              // 중앙 재생 버튼: 전역 상태와 AudioService를 사용하여 재생/일시정지/이어재생 처리
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 64,
                ),
                onPressed: () async {
                  if (isPlaying) {
                    await ref.read(audioServiceProvider).pause(ref);
                  } else {
                    final trackUrl = playbackState.trackUrl;
                    if (trackUrl.isNotEmpty) {
                      await ref.read(audioServiceProvider).resume(ref);
                    } else {
                      // 만약 트랙이 로드되지 않았다면, 기존 onToggle 콜백을 호출할 수도 있습니다.
                      widget.onToggle();
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.repeat, color: Colors.white70, size: 28),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
