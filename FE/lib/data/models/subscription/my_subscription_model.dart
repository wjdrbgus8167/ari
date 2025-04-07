import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';

class MySubscriptionModel {
  final List<MonthlySubscription> monthly;
  final List<ArtistSubscription> artists;

  MySubscriptionModel({
    required this.monthly,
    required this.artists,
  });

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MySubscriptionModel(
      monthly: (json['monthly'] as List)
          .map((monthly) => MonthlySubscription.fromJson(monthly))
          .toList(),
      artists: (json['artist'] as List)
          .map((artist) => ArtistSubscription.fromJson(artist))
          .toList(),
    );
  }
}

class MonthlySubscription {
  final double price;
  final String subscribeAt;  // 필드명 변경
  final String? expiredAt;   // null 가능성 추가

  MonthlySubscription({
    required this.price,
    required this.subscribeAt,
    this.expiredAt,
  });

  factory MonthlySubscription.fromJson(Map<String, dynamic> json) {
    return MonthlySubscription(
      price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'],
      subscribeAt: json['subscribeAt'],
      expiredAt: json['expiredAt'],  // null 허용
    );
  }
}

class ArtistSubscription {
  final String artistNickname;
  final double price;
  final String subscribeAt;  // 필드명 변경
  final String? expiredAt;   // null 가능성 추가

  ArtistSubscription({
    required this.artistNickname,
    required this.price,
    required this.subscribeAt,
    this.expiredAt,
  });

  factory ArtistSubscription.fromJson(Map<String, dynamic> json) {
    return ArtistSubscription(
      artistNickname: json['artistNickname'],
      price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'],
      subscribeAt: json['subscribeAt'],
      expiredAt: json['expiredAt'],  // null 허용
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artistNickname': artistNickname,
      'price': price,
      'subscribeAt': subscribeAt,
      'expiredAt': expiredAt,
    };
  }
}