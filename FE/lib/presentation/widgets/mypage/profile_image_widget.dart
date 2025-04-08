// presentation/widgets/profile/profile_image_widget.dart
import 'dart:io';
import 'package:ari/presentation/viewmodels/mypage/edit_profile_viewmodel.dart';
import 'package:ari/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileImageWidget extends ConsumerWidget {
  const ProfileImageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final viewModel = ref.watch(profileEditViewModelProvider);

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // 프로필 이미지
          ClipOval(
            child: Container(
              width: 100,
              height: 100,
              color: const Color(0xFF282828),
              child: _buildImageContent(profile, viewModel),
            ),
          ),
          
          // 카메라 버튼
          GestureDetector(
            onTap: () => viewModel.selectProfileImage(),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF424242),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageContent(ProfileModel profile, ProfileEditViewModel viewModel) {
    // 로컬에서 선택된 이미지 파일이 있는 경우
    if (profile.profileImageFile != null) {
      // 실제 앱에서는 선택된 이미지 파일 표시
      // return Image.file(File(profile.profileImageFile!), fit: BoxFit.cover);
      
      // 시뮬레이션 (선택된 이미지 아이콘으로 표현)
      return Container(
        color: const Color(0xFF383838),
        child: const Center(
          child: Icon(
            Icons.image, 
            size: 50,
            color: Colors.white70,
          ),
        ),
      );
    }
    
    // 기존 프로필 이미지 URL이 있는 경우
    if (profile.profileImageUrl != null) {
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
    return const Center(
      child: Icon(
        Icons.person,
        size: 50,
        color: Color(0xFF989595),
      ),
    );
  }
}