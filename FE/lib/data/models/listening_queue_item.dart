import 'package:ari/domain/entities/track.dart';
import 'package:flutter/material.dart';

class ListeningQueueItem {
  final Track track;
  final String uuid; // 고유 ID

  ListeningQueueItem({required this.track}) : uuid = UniqueKey().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListeningQueueItem && uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get uniqueId => uuid;
}
