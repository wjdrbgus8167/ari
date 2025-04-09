// providers/profile/profile_provider.dart
import 'dart:io';
import 'package:ari/data/repositories/user_repository.dart';
import 'package:ari/domain/entities/profile.dart';
import 'package:ari/domain/repositories/user/user_repository.dart';
import 'package:ari/domain/usecases/user/user_usecase.dart';
import 'package:ari/presentation/viewmodels/mypage/edit_profile_viewmodel.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ProfileModel 클래스 정의
class ProfileModel {
  final String name;
  final String introduction;
  final String instagramId;
  final String? profileImageUrl;
  final String? profileImageFile; // 로컬 이미지 파일 경로

  ProfileModel({
    required this.name,
    required this.introduction,
    required this.instagramId,
    this.profileImageUrl,
    this.profileImageFile,
  });

  ProfileModel copyWith({
    String? name,
    String? introduction,
    String? instagramId,
    String? profileImageUrl,
    String? profileImageFile,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      introduction: introduction ?? this.introduction,
      instagramId: instagramId ?? this.instagramId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImageFile: profileImageFile ?? this.profileImageFile,
    );
  }

  // Profile 도메인 엔티티로 변환
  Profile toEntity() {
    return Profile(
      memberId: 0, // 서버에서 관리하므로 기본값 설정
      nickname: name,
      bio: introduction,
      instagram: instagramId,
      profileImageUrl: profileImageUrl,
      // 추가 필드 (필요한 경우 서버에서 가져옴)
      followerCount: null,
      followingCount: null,
    );
  }

  // Profile 도메인 엔티티에서 변환
  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      name: profile.nickname,
      introduction: profile.bio ?? '',
      instagramId: profile.instagram ?? '',
      profileImageUrl: profile.profileImageUrl,
      profileImageFile: null, // 엔티티에는 로컬 파일 정보가 없음
    );
  }

  factory ProfileModel.initial() {
    return ProfileModel(
      name: '',
      introduction: '',
      instagramId: '',
      profileImageUrl: null,
      profileImageFile: null,
    );
  }
}

// Profile 상태를 관리하는 StateNotifier
class ProfileNotifier extends StateNotifier<ProfileModel> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  ProfileNotifier({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
  }) : super(ProfileModel.initial());

  void updateProfile({
    String? name,
    String? introduction,
    String? instagramId,
    String? profileImageUrl,
    String? profileImageFile,
  }) {
    state = state.copyWith(
      name: name,
      introduction: introduction,
      instagramId: instagramId,
      profileImageUrl: profileImageUrl,
      profileImageFile: profileImageFile,
    );
  }

  // 프로필 이미지 파일 업데이트 (로컬 파일 경로)
  void updateProfileImageFile(String filePath) {
    state = state.copyWith(profileImageFile: filePath);
  }

  // 프로필 저장 함수
  Future<bool> saveProfile() async {
    try {
      // 프로필 엔티티 생성
      final profile = state.toEntity();
      
      // 선택된 이미지 파일이 있는지 확인
      MultipartFile? imageFile;
      if (state.profileImageFile != null) {
        imageFile = await MultipartFile.fromFile(state.profileImageFile!, filename: state.profileImageFile!.split('/').last);
      }
      
      // API 호출 실행
      final result = await updateUserProfileUseCase(profile, imageFile);
      
      // 결과 처리
      return result.fold(
        (failure) {
          // 에러 처리
          debugPrint('Error updating profile: ${failure.toString()}');
          return false;
        }, 
        (_) {
          // 성공 시, 필요한 경우 프로필 다시 로드
          loadProfile();
          
          // 이미지 파일 참조 제거 (이미 서버에 업로드됨)
          if (state.profileImageFile != null) {
            state = state.copyWith(profileImageFile: null);
          }
          
          return true;
        }
      );
    } catch (e) {
      debugPrint('Error saving profile: $e');
      return false;
    }
  }

  // 프로필 데이터 로드 함수
  Future<bool> loadProfile() async {
    try {
      // API 호출 실행
      final result = await getUserProfileUseCase();
      
      // 결과 처리
      return result.fold(
        (failure) {
          // 에러 처리
          debugPrint('Error loading profile: ${failure.toString()}');
          return false;
        }, 
        (profile) {
          // 성공 시 상태 업데이트
          state = ProfileModel.fromEntity(profile);
          return true;
        }
      );
    } catch (e) {
      debugPrint('Error loading profile: $e');
      return false;
    }
  }
}

// Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  // 실제 구현체 반환
  return UserRepositoryImpl(dataSource: ref.read(userRemoteDataSourceProvider));
});

// UseCase Provider
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserProfileUseCase(repository);
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUserProfileUseCase(repository);
});

// ProfileNotifier의 Provider 정의
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileModel>((ref) {
  final getUserProfileUseCase = ref.watch(getUserProfileUseCaseProvider);
  final updateUserProfileUseCase = ref.watch(updateUserProfileUseCaseProvider);
  
  return ProfileNotifier(
    getUserProfileUseCase: getUserProfileUseCase,
    updateUserProfileUseCase: updateUserProfileUseCase,
  );
});

// 프로필 수정 상태 관리 Provider (로딩 상태 등)
final profileEditingProvider = StateProvider<bool>((ref) => false);