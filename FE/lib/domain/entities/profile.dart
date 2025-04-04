import 'dart:io';

class Profile {
  final int memberId;
  final String nickname;
  final String? instagram;
  final String? bio;
  final String? profileImageUrl;
  final int? followerCount;
  final int? followingCount;

  const Profile({
    required this.memberId,
    required this.nickname,
    this.instagram,
    this.bio,
    this.profileImageUrl,
    this.followerCount,
    this.followingCount,
  });

  // 이미지 처리를 위한 팩토리 메서드
  Profile copyWithImageSource({
    String? profileImageUrl,
    File? profileImageFile,
  }) {
    return Profile(
      memberId: memberId,
      nickname: nickname,
      instagram: instagram,
      bio: bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followerCount: followerCount,
      followingCount: followingCount,
    );
  }
}
