import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/providers/playback/playback_progress_provider.dart';
import 'package:ari/core/services/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class PlaybackControls extends ConsumerStatefulWidget {
  final VoidCallback onToggle;
  const PlaybackControls({super.key, required this.onToggle});

  @override
  _PlaybackControlsState createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends ConsumerState<PlaybackControls> {
  double _sliderValue = 0.0;
  bool _isUserInteracting = false;
  LoopMode _currentLoopMode = LoopMode.off;
  bool _isShuffleEnabled = false;

  @override
  void initState() {
    super.initState();
    _initLoopAndShuffle();
  }

  Future<void> _initLoopAndShuffle() async {
    final player = ref.read(audioServiceProvider).audioPlayer;
    final shuffle = player.shuffleModeEnabled;
    final loop = player.loopMode;
    setState(() {
      _isShuffleEnabled = shuffle;
      _currentLoopMode = loop;
    });
  }

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

    if (!_isUserInteracting &&
        mounted &&
        duration.inMilliseconds > 0 &&
        position.inMilliseconds <= duration.inMilliseconds) {
      final newValue = position.inMilliseconds / duration.inMilliseconds;
      if ((_sliderValue - newValue).abs() > 0.01) {
        setState(() {
          _sliderValue = newValue;
        });
      }
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
              // 셔플 버튼
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: _isShuffleEnabled ? Colors.white : Colors.white38,
                  size: 28,
                ),
                onPressed: () async {
                  await ref.read(audioServiceProvider).toggleShuffle();
                  final enabled =
                      ref
                          .read(audioServiceProvider)
                          .audioPlayer
                          .shuffleModeEnabled;
                  setState(() {
                    _isShuffleEnabled = enabled;
                  });
                },
              ),
              // 이전 곡
              IconButton(
                icon: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () async {
                  await ref.read(audioServiceProvider).playPrevious();
                },
              ),
              // 중앙 재생 버튼
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
                      widget.onToggle();
                    }
                  }
                },
              ),
              // 다음 곡
              IconButton(
                icon: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () async {
                  await ref.read(audioServiceProvider).playNext();
                },
              ),
              // 루프 버튼
              IconButton(
                icon: Icon(
                  _currentLoopMode == LoopMode.one
                      ? Icons.repeat_one
                      : Icons.repeat,
                  color:
                      _currentLoopMode == LoopMode.off
                          ? Colors.white38
                          : Colors.white,
                  size: 28,
                ),
                onPressed: () async {
                  LoopMode newMode;
                  if (_currentLoopMode == LoopMode.off) {
                    newMode = LoopMode.all;
                  } else if (_currentLoopMode == LoopMode.all) {
                    newMode = LoopMode.one;
                  } else {
                    newMode = LoopMode.off;
                  }
                  await ref.read(audioServiceProvider).setLoopMode(newMode);
                  setState(() {
                    _currentLoopMode = newMode;
                  });
                },
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
