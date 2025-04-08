import 'dart:io';
import 'package:ari/domain/entities/profile.dart';
import 'package:ari/domain/usecases/user/user_usecase.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';


// ProfileEditState
class ProfileEditState {
  final Profile? profile;
  final bool isLoading;
  final String? errorMessage;
  final bool isUpdating;
  final bool isSuccess;

  ProfileEditState({
    required this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.isUpdating = false,
    this.isSuccess = false,
  });

  // 상태 복사본 생성 (일부 필드 업데이트 가능)
  ProfileEditState copyWith({
    Profile? profile,
    bool? isLoading,
    String? errorMessage,
    bool? isUpdating,
    bool? isSuccess,
  }) {
    return ProfileEditState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isUpdating: isUpdating ?? this.isUpdating,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ProfileEditNotifier
class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final ImagePicker _imagePicker = ImagePicker();

  ProfileEditNotifier(
    this._updateUserProfileUseCase,
    this._getUserProfileUseCase,
  ) : super(ProfileEditState(
        profile: Profile(
          memberId: 1,
          nickname: '',
        ),
      )) {
    // 초기화 시 프로필 정보를 가져옴
    loadUserProfile();
  }

  // 프로필 정보 로드
  Future<void> loadUserProfile() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final result = await _getUserProfileUseCase();
      
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (profile) => state = state.copyWith(
          profile: profile,
          isLoading: false,
        ),
      );
      
      // 로드 결과 로깅으로 디버깅
      // print('Profile loaded: ${state.profile.nickname}, ${state.profile.bio}, ${state.profile.instagram}');
    } catch (e) {
      print('Failed to load profile: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '프로필 정보를 가져오는데 실패했습니다: $e',
      );
    }
  }

  // 프로필 이미지 선택
  Future<void> pickProfileImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);
    } catch (e) {
      state = state.copyWith(
        errorMessage: '이미지를 선택하는데 실패했습니다: $e',
      );
    }
  }

  // 프로필 정보 업데이트
  Future<void> updateProfile() async {
    try {
      // final request = state.profile.toUpdateProfileRequest();
      
      // // 업데이트할 내용이 없으면 무시
      // if (request.isEmpty) {
      //   state = state.copyWith(
      //     errorMessage: '업데이트할 내용이 없습니다.',
      //   );
      //   return;
      // }

      // state = state.copyWith(
      //   isUpdating: true,
      //   errorMessage: null,
      //   isSuccess: false,
      // );

      // final result = await _updateUserProfileUseCase(request, request.profileImage);
      
      // result.fold(
      //   (failure) => state = state.copyWith(
      //     isUpdating: false,
      //     errorMessage: failure.message,
      //     isSuccess: false,
      //   ),
      //   (profile) => state = state.copyWith(
      //     profile: profile,
      //     isUpdating: false,
      //     isSuccess: true,
      //   ),
      // );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: '프로필 업데이트에 실패했습니다: $e',
        isSuccess: false,
      );
    }
  }

  // 오류 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // 업데이트 성공 상태 초기화
  void clearUpdateSuccess() {
    state = state.copyWith(isSuccess: false);
  }
}

// GetUserProfileUseCase 프로바이더
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.read(userRepositoryProvider));
});

// UpdateUserProfileUseCase 프로바이더
final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  return UpdateUserProfileUseCase(ref.read(userRepositoryProvider));
});

// ViewModel 프로바이더
final profileEditProvider = StateNotifierProvider<ProfileEditNotifier, ProfileEditState>((ref) {
  final updateUseCase = ref.watch(updateUserProfileUseCaseProvider);
  final getUseCase = ref.watch(getUserProfileUseCaseProvider);
  return ProfileEditNotifier(updateUseCase, getUseCase);
});