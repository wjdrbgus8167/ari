import 'package:ari/presentation/widgets/mypage/profile_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 실제 프로젝트에 맞게 import 경로 수정 필요

// ViewModel import 경로는 실제 프로젝트 구조에 맞게 수정 필요
import 'package:ari/presentation/viewmodels/mypage/edit_profile_viewmodel.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 로드된 후 프로필 다시 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileEditProvider.notifier).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileEditProvider);
    final notifier = ref.read(profileEditProvider.notifier);
    
    // 에러 메시지 표시
    ref.listen<ProfileEditState>(profileEditProvider, (previous, current) {
      // 에러 메시지 처리
      if (previous?.errorMessage != current.errorMessage && 
          current.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(current.errorMessage!)),
        );
      }
      
      // 성공 시 처리
      if (previous?.isSuccess != current.isSuccess && current.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 성공적으로 업데이트되었습니다.')),
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '내 정보 수정',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 이미지 섹션
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Stack(
                      children: [
                        // // 프로필 이미지
                        // Container(
                        //   width: 100,
                        //   height: 100,
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFF282828),
                        //     shape: BoxShape.circle,
                        //     image: state.profile?.profileImageFile != null
                        //         ? DecorationImage(
                        //             image: FileImage(state.profile?.profileImageFile!),
                        //             fit: BoxFit.cover,
                        //           )
                        //         : state.profile?.profileImageUrl != null
                        //             ? DecorationImage(
                        //                 image: NetworkImage(state.profile?.profileImageUrl!),
                        //                 fit: BoxFit.cover,
                        //               )
                        //             : null,
                        //   ),
                        //   child: state.profile?.profileImageUrl == null && state.profile == null
                        //       ? const Icon(Icons.person, color: Colors.white, size: 50)
                        //       : null,
                        // ),
                        // 이미지 선택 버튼
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => notifier.pickProfileImage(),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFF424242),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // // 이름 입력 필드
                // ProfileInputField(
                //   label: '이름',
                //   initialValue: state.profile.nickname,
                //   onChanged: (value) => notifier.updateNickname(value),
                // ),
                // const SizedBox(height: 20),
                
                // // 소개글 입력 필드
                // ProfileInputField(
                //   label: '소개글',
                //   initialValue: state.profile.bio,
                //   onChanged: (value) => notifier.updateBio(value),
                //   maxLines: 3,
                // ),
                // const SizedBox(height: 20),
                
                // // 인스타그램 ID 입력 필드
                // ProfileInputField(
                //   label: '인스타그램 ID',
                //   initialValue: state.profile.instagramId,
                //   onChanged: (value) => notifier.updateInstagramId(value),
                // ),
                // const SizedBox(height: 40),
                
                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isUpdating 
                      ? null // 업데이트 중이면 버튼 비활성화
                      : () => notifier.updateProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state.isUpdating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          '저장하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}