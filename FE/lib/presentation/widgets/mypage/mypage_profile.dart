import 'package:flutter/material.dart';

class MypageProfile extends StatelessWidget {
  final String? name;
  final String? instagramId;
  final String? bio;
  final int? followers;
  final int? following;
  final String? profileImage;
  final String? secondaryImage;
  final VoidCallback onEditPressed;

  const MypageProfile({
    super.key,
    required this.name,
    required this.instagramId,
    required this.bio,
    required this.followers,
    required this.following,
    this.profileImage = "https://placehold.co/100x100",
    this.secondaryImage = "https://placehold.co/100x100",
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 0.50, color: Color(0xFF838282)),
            ),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left side - Profile information
              Expanded( // Expanded로 감싸서 사용 가능한 공간을 효율적으로 활용
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // 이미지가 있으면 이미지 사용, 없으면 그라데이션 배경 사용
                        image: profileImage != null && profileImage != "https://placehold.co/100x100"
                            ? DecorationImage(
                                image: NetworkImage(profileImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        // 이미지가 없을 때만 그라데이션 보여주기
                        gradient: profileImage == null || profileImage == "https://placehold.co/100x100"
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFD8C0FF), // 연한 보라색
                                  Color(0xFFB5E0FF), // 연한 파란색
                                ],
                              )
                            : null,
                        // 이미지가 없을 때만 테두리 적용
                        border: profileImage == null || profileImage == "https://placehold.co/100x100"
                            ? Border.all(
                                color: Color(0xFF00A3FF), // 테두리 색상 (파란색)
                                width: 2.0,
                              )
                            : null,
                      ),
                      // 이미지가 없을 때만 아이콘 표시
                      child: profileImage == null || profileImage == "https://placehold.co/100x100"
                          ? Center(
                              child: Icon(
                                Icons.person, // person 아이콘 (사용자 아이콘)
                                size: 50,
                                color: Colors.black54, // 어두운 회색
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Name and instagram ID
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          name ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '@$instagramId',
                          style: TextStyle(
                            color: const Color(0xFFD9D9D9),
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Bio
                    ...(bio != null && bio!.isNotEmpty
                        ? [
                            Text(
                              bio ?? "",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis, // 오버플로우 처리 추가
                            ),
                            const SizedBox(height: 15),
                          ]
                        : [const SizedBox(height: 0)]),
                    // Followers and Following
                    Row(
                      children: [
                        Text(
                          '$followers Followers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '$following Following',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 여백 추가
              const SizedBox(width: 10),

              // Edit profile button
              GestureDetector(
                onTap: onEditPressed,
                child: Text(
                  '내 정보 수정',
                  style: TextStyle(
                    color: const Color(0xFFD9D9D9),
                    fontSize: 12,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                    decorationThickness: 1.0,
                    decorationStyle: TextDecorationStyle.solid,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}