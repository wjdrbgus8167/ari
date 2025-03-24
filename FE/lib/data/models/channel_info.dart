class ChannelInfo {
  final String memberName;
  final String profileImageUrl;
  final int subscriberCount;
  final bool isFollowed;

  ChannelInfo({
    required this.memberName, // 채널명(닉네임)
    required this.profileImageUrl,
    required this.subscriberCount,
    required this.isFollowed, // 내가 이 채널을 팔로우 했는지 여부
  });

  factory ChannelInfo.fromJson(Map<String, dynamic> json) {
    return ChannelInfo(
      memberName: json['memberName'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      subscriberCount: json['subscriberCount'] ?? 0,
      isFollowed: json['followed_yn'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'memberName': memberName,
      'profileImageUrl': profileImageUrl,
      'followed_yn': isFollowed,
    };

    // 구독자 수가 0일 경우 subscriberCount를 포함하지 않음: 구독자가 0이라면 일반 회원이기 때문
    if (subscriberCount > 0) {
      data['subscriberCount'] = subscriberCount;
    }

    return data;
  }
}
