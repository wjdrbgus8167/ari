import 'dart:io';
import 'package:ari/domain/entities/profile.dart';
import 'package:dio/dio.dart';

import 'dart:convert';

class UpdateProfileRequest {
  final String? nickname;
  final String? bio;
  final String? instagramId;
  final MultipartFile? profileImage;

  UpdateProfileRequest({
    this.nickname,
    this.bio,
    this.instagramId,
    this.profileImage,
  });

  FormData toFormData() {
    final formData = FormData();
    
    // 프로필 정보를 JSON 문자열로 변환하여 'profile' 필드에 추가
    final Map<String, dynamic> profileData = {};
    
    if (nickname != null) {
      profileData['nickname'] = nickname;
    }
    
    if (bio != null) {
      profileData['bio'] = bio;
    }
    
    if (instagramId != null) {
      profileData['instagramId'] = instagramId;
    }
    
    // 빈 객체라도 'profile' 필드는 항상 추가
    formData.fields.add(MapEntry('profile', jsonEncode(profileData)));
    
    // 프로필 이미지가 있으면 'profileImage' 필드에 추가
    if (profileImage != null) {
      formData.files.add(MapEntry('profileImage', profileImage!));
    } else {
      // 이미지가 없어도 빈 파일이나 더미 파일을 추가
      // 방법 1: 빈 바이트 배열로 빈 파일 만들기
      formData.files.add(MapEntry(
        'profileImage',
        MultipartFile.fromBytes([], filename: 'empty.jpg')
      ));
      
      // 또는 방법 2: 필드만 비어있게 추가 (서버 구현에 따라 다름)
      // formData.fields.add(MapEntry('profileImage', ''));
    }
    
    return formData;
  }

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