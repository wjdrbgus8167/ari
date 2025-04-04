// lib/providers/playback/cover_image_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'playback_state_provider.dart';

final coverImageProvider = Provider<ImageProvider<Object>>((ref) {
  final playbackState = ref.watch(playbackProvider);
  if (playbackState.coverImageUrl.isNotEmpty) {
    return NetworkImage(playbackState.coverImageUrl);
  } else {
    return const AssetImage('assets/images/default_album_cover.png');
  }
});
