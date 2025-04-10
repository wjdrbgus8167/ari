// presentation/viewmodels/mypage/edit_profile_viewmodel.dart
import 'dart:io';
import 'package:ari/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditViewModel {
  final Ref ref;
  final TextEditingController nameController;
  final TextEditingController introductionController;
  final TextEditingController instagramIdController;
  bool isLoading = false;
  bool _initialized = false; // 초기화 여부를 추적하는 플래그 추가
  
  // 이미지 선택 여부를 알려주는 getter
  bool get hasSelectedImage => ref.read(profileProvider).profileImageFile != null;
  
  // 초기화 완료 여부를 확인하는 getter
  bool get isInitialized => _initialized;

  ProfileEditViewModel(this.ref)
      : nameController = TextEditingController(),
        introductionController = TextEditingController(),
        instagramIdController = TextEditingController();
  
  void _initControllers() {
    final profile = ref.read(profileProvider);
    // 빈 값이 아닌지 확인 후 설정
    if (profile.name.isNotEmpty) {
      nameController.text = profile.name;
    }
    if (profile.introduction.isNotEmpty) {
      introductionController.text = profile.introduction;
    }
    if (profile.instagramId.isNotEmpty) {
      instagramIdController.text = profile.instagramId;
    }
    _initialized = true;
  }
  
  // 프로필 정보 초기 로드
  Future<bool> loadProfile() async {
    isLoading = true;
    ref.read(profileEditingProvider.notifier).state = true;
    
    final success = await ref.read(profileProvider.notifier).loadProfile();
    
    if (success) {
      // 컨트롤러 초기화 (데이터 로드 성공 후에만)
      _initControllers();
    }
    
    isLoading = false;
    ref.read(profileEditingProvider.notifier).state = false;
    
    return success;
  }

  // 텍스트 필드 값을 업데이트 (이미지는 그대로 유지)
  void updateTextFields() {
    ref.read(profileProvider.notifier).updateProfile(
          name: nameController.text,
          introduction: introductionController.text,
          instagramId: instagramIdController.text,
        );
  }

  // 이미지 선택 처리
  Future<void> selectProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      debugPrint('이미지 선택됨: ${pickedFile.path}');
      ref.read(profileProvider.notifier).updateProfileImageFile(pickedFile.path);
    }
  }

  // 카메라로 이미지 촬영
  Future<void> takeProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      ref.read(profileProvider.notifier).updateProfileImageFile(pickedFile.path);
    }
  }

  // 이미지 미리보기 가져오기 (UI 표시용)
  Widget getImagePreview() {
    final profile = ref.read(profileProvider);
    
    // 선택한 이미지 파일이 있는 경우
    if (profile.profileImageFile != null) {
      return Image.file(
        File(profile.profileImageFile!),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }
    
    // 기존 이미지 URL이 있는 경우
    if (profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty) {
      return Image.network(
        profile.profileImageUrl!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white54),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error, color: Colors.red, size: 40),
          );
        },
      );
    }
    
    // 이미지가 없는 경우 기본 아이콘
    return const Icon(
      Icons.person,
      size: 50,
      color: Color(0xFF989595),
    );
  }

  // 모든 프로필 정보(텍스트+이미지)를 함께 저장
  Future<bool> saveProfile() async {
    isLoading = true;
    ref.read(profileEditingProvider.notifier).state = true;
    
    // 현재 입력값으로 텍스트 필드 업데이트
    updateTextFields();
    
    // 저장 로직 실행 (이미지와 텍스트 정보 함께 전송)
    final success = await ref.read(profileProvider.notifier).saveProfile();

    isLoading = false;
    ref.read(profileEditingProvider.notifier).state = false;
    
    return success;
  }

  void dispose() {
    nameController.dispose();
    introductionController.dispose();
    instagramIdController.dispose();
  }
}

final profileEditViewModelProvider = Provider.autoDispose<ProfileEditViewModel>((ref) {
  return ProfileEditViewModel(ref);
});