class Settlement {
  final double streamingSettlement;
  final double subscribeSettlement;

  Settlement({
    required this.streamingSettlement,
    required this.subscribeSettlement,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      streamingSettlement: double.parse(json['regularSettlement'] as String) ,
      subscribeSettlement: double.parse(json['artistSettlement'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streamingSettlement': streamingSettlement,
      'subscribeSettlement': subscribeSettlement,
    };
  }

  // 총액 계산 도우미 메서드
  double get totalSettlement => streamingSettlement + subscribeSettlement;
}