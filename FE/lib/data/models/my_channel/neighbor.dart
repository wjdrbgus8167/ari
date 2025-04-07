/// 이웃(팔로워/팔로잉) 모델 클래스
class Neighbor {
  final int memberId;
  final String memberName;
  final String profileImageUrl;
  final int followerCount;
  final int subscriberCount;
  final bool subscribeYn;

  Neighbor({
    required this.memberId,
    required this.memberName,
    required this.profileImageUrl,
    required this.followerCount,
    this.subscriberCount = 0,
    this.subscribeYn = false,
  });

  factory Neighbor.fromJson(Map<String, dynamic> json) {
    return Neighbor(
      memberId: json['memberId'] ?? 0,
      memberName: json['memberName'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      followerCount: json['followerCount'] ?? 0,
      subscriberCount: json['subscriberCount'] ?? 0,
      subscribeYn: json['subscribeYn'] ?? false,
    );
  }
}

/// 팔로워 목록, 몇 명인지 담을 모델 클래스
/// API에서 팔로워 목록 받아서 저장, 관리
class FollowerResponse {
  final List<Neighbor> followers;
  final int followerCount;

  FollowerResponse({required this.followers, required this.followerCount});

  /// API에서 받은 JSON 데이터 -> FollowerResponse
  factory FollowerResponse.fromJson(Map<String, dynamic> json) {
    final followersList = json['followers'] as List<dynamic>? ?? [];

    return FollowerResponse(
      followers:
          followersList
              .map((followerJson) => Neighbor.fromJson(followerJson))
              .toList(),
      followerCount: json['followerCount'] ?? 0,
    );
  }
}

/// 팔로잉 목록, 몇 명인지 담을 모델 클래스
/// API에서 팔로잉잉 목록 받아서 저장 관리
class FollowingResponse {
  final List<Neighbor> followings;
  final int followingCount;

  FollowingResponse({required this.followings, required this.followingCount});

  /// [return] : 생성된 FollowingResponse 객체
  factory FollowingResponse.fromJson(Map<String, dynamic> json) {
    final followingsList = json['followings'] as List<dynamic>? ?? [];

    return FollowingResponse(
      followings:
          followingsList
              .map((followingJson) => Neighbor.fromJson(followingJson))
              .toList(),
      followingCount: json['followingCount'] ?? 0,
    );
  }
}
