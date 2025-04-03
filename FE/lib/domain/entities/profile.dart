class Profile {
  int memberId;
  String nickname;
  String? bio;
  String? profileImageUrl;
  int? followerCount;
  int? followingCount;

  Profile({ // const 생성자로 변경
    required this.memberId,
    required this.nickname,
    this.bio,
    this.profileImageUrl,
    this.followerCount,
    this.followingCount,
  });
}