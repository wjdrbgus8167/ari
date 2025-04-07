// 구독 모델
import 'package:flutter/material.dart';

class SubscriptionHistory {
  final String period;
  final String type; // 'regular' 또는 'artist'
  final double amount;
  final int streamingCount;
  
  SubscriptionHistory({
    required this.period,
    required this.type,
    required this.amount,
    required this.streamingCount,
  });
}

// 아티스트 모델
class Artist {
  final String name;
  final String imageUrl;
  final double allocation; // 할당 비율 (%)
  final int streamingCount;
  final Color color; // 차트에 사용될 색상
  
  Artist({
    required this.name,
    required this.imageUrl,
    required this.allocation,
    required this.streamingCount,
    required this.color,
  });
}