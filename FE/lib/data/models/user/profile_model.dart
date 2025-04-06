import 'dart:io';
import 'package:ari/domain/entities/profile.dart';
import 'package:dio/dio.dart';

class UpdateProfileRequest {
  final String? nickname;
  final String? bio;
  final String? instagramId;
  final File? profileImage;

  UpdateProfileRequest({
    this.nickname,
    this.bio,
    this.instagramId,
    this.profileImage,
  });


  /// Convert the update profile request to FormData
  FormData toFormData() {
    final formData = FormData();

    // Add text fields if they are not null
    if (nickname != null) {
      formData.fields.add(MapEntry('nickname', nickname!));
    }

    if (bio != null) {
      formData.fields.add(MapEntry('bio', bio!));
    }

    if (instagramId != null) {
      formData.fields.add(MapEntry('instagramId', instagramId!));
    }

    // Add profile image file if it exists
    if (profileImage != null) {
      formData.files.add(MapEntry(
        'profileImage',
        MultipartFile.fromFileSync(
          profileImage!.path,
          filename: 'profile_image.${profileImage!.path.split('.').last}',
        ),
      ));
    }

    return formData;
  }

  /// Check if the request is empty (no updates)
  bool get isEmpty =>
      nickname == null &&
      bio == null &&
      instagramId == null &&
      profileImage == null;
}

class ProfileResponse {
  final int memberId;
  final String nickName;
  final String? instagram;
  final String? bio;
  final String? profileImageUrl;
  final int followerCount;
  final int followingCount;

  ProfileResponse({
    required this.memberId,
    required this.nickName,
    this.instagram,
    this.bio,
    this.profileImageUrl,
    required this.followerCount,
    required this.followingCount,
  });

  /// JSON으로부터 ProfileResponse 객체를 생성하는 팩토리 생성자
  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      memberId: json['memberId'],
      nickName: json['nickName'],
      instagram: json['instagram'],
      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'],
      followerCount: json['followerCount'],
      followingCount: json['followingCount'],
    );
  }

  /// 객체를 JSON 맵으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'nickName': nickName,
      'instagram': instagram,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followerCount': followerCount,
      'followingCount': followingCount,
    };
  }

  Profile toEntity() {
    return Profile(
      memberId: memberId,
      nickname: nickName,
      instagram: instagram,
      bio: bio,
      profileImageUrl: profileImageUrl,
      followerCount: followerCount,
      followingCount: followingCount,
    );
  }

  /// 객체의 복사본을 생성하는 CopyWith 메서드
  ProfileResponse copyWith({
    int? memberId,
    String? nickName,
    String? instagram,
    String? bio,
    String? profileImageUrl,
    int? followerCount,
    int? followingCount,
  }) {
    return ProfileResponse(
      memberId: memberId ?? this.memberId,
      nickName: nickName ?? this.nickName,
      instagram: instagram ?? this.instagram,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileResponse &&
          runtimeType == other.runtimeType &&
          memberId == other.memberId &&
          nickName == other.nickName &&
          instagram == other.instagram &&
          bio == other.bio &&
          profileImageUrl == other.profileImageUrl &&
          followerCount == other.followerCount &&
          followingCount == other.followingCount;

  @override
  int get hashCode =>
      memberId.hashCode ^
      nickName.hashCode ^
      instagram.hashCode ^
      bio.hashCode ^
      profileImageUrl.hashCode ^
      followerCount.hashCode ^
      followingCount.hashCode;

  @override
  String toString() {
    return 'ProfileResponse(memberId: $memberId, nickName: $nickName, instagram: $instagram, bio: $bio, profileImageUrl: $profileImageUrl, followerCount: $followerCount, followingCount: $followingCount)';
  }
}