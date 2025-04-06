/// 채널 정보 모델 클래스
/// 채널 소유자의 정보와 팔로우 관련 정보 포함
class ChannelInfo {
  final String memberId; // 회원 ID
  final String memberName; // 회원 이름 (채널명/닉네임)
  final String? profileImageUrl; // 프로필 이미지 URL (null 가능)
  final String introduction; // 소개글
  final int subscriberCount; // 구독자 수
  final int followerCount; // 팔로워 수
  final int followingCount; // 팔로잉 수
  final bool isArtist; // 아티스트 여부
  final bool isFollowed; // 내가 이 채널을 팔로우 했는지 여부
  final String? followId; // 팔로우 관계 ID (언팔로우 시 필요)
  final int? fantalkChannelId; // 팬톡 채널 ID

  ChannelInfo({
    required this.memberId,
    required this.memberName,
    this.profileImageUrl,
    required this.introduction,
    required this.subscriberCount,
    required this.followerCount,
    required this.followingCount,
    required this.isArtist,
    required this.isFollowed,
    this.followId,
    this.fantalkChannelId,
  });

  /// JSON에서 ChannelInfo 객체 생성
  factory ChannelInfo.fromJson(Map<String, dynamic> json) {
    return ChannelInfo(
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      introduction: json['introduction'] ?? '',
      subscriberCount: json['subscriberCount'] ?? 0,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isArtist: json['isArtist'] ?? false,
      isFollowed: json['followedYn'] ?? false,
      followId: json['followId'],
      fantalkChannelId: json['fantalkChannelId'],
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'memberId': memberId,
      'memberName': memberName,
      'introduction': introduction,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'isArtist': isArtist,
      'followedYn': isFollowed,
    };

    // null이 아닌 경우에만 포함
    if (profileImageUrl != null) {
      data['profileImageUrl'] = profileImageUrl;
    }

    // 구독자 수가 0일 경우 subscriberCount를 포함하지 않음: 구독자가 0이라면 일반 회원이기 때문
    if (subscriberCount > 0) {
      data['subscriberCount'] = subscriberCount;
    }

    // followId가 null이 아닌 경우에만 포함
    if (followId != null) {
      data['followId'] = followId;
    }

    // fantalkChannelId가 null이 아닌 경우에만 포함
    if (fantalkChannelId != null) {
      data['fantalkChannelId'] = fantalkChannelId;
    }

    return data;
  }

  /// 객체 복사 및 속성 업데이트
  ChannelInfo copyWith({
    String? memberId,
    String? memberName,
    String? profileImageUrl,
    String? introduction,
    int? subscriberCount,
    int? followerCount,
    int? followingCount,
    bool? isArtist,
    bool? isFollowed,
    String? followId,
    int? fantalkChannelId,
  }) {
    return ChannelInfo(
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      introduction: introduction ?? this.introduction,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      isArtist: isArtist ?? this.isArtist,
      isFollowed: isFollowed ?? this.isFollowed,
      followId: followId ?? this.followId,
      fantalkChannelId: fantalkChannelId ?? this.fantalkChannelId,
    );
  }
}
