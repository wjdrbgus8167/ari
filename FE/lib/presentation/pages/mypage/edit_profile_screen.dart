// presentation/pages/mypage/edit_profile_screen.dart
import 'package:ari/presentation/viewmodels/mypage/edit_profile_viewmodel.dart';
import 'package:ari/presentation/widgets/mypage/profile_image_widget.dart';
import 'package:ari/presentation/widgets/mypage/profile_input_field.dart';
import 'package:ari/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final ProfileEditViewModel viewModel;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    viewModel = ref.read(profileEditViewModelProvider);
    
    // 데이터 로드 (첫 로드 시에만 필요하다면)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 필요시 데이터 로드 로직
      // ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  // 사용자가 뒤로 가려고 할 때 변경사항이 있다면 확인 다이얼로그 표시
  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('변경사항 저장'),
        content: const Text('변경사항이 있습니다. 저장하지 않고 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('나가기'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  // 변경사항 감지 함수
  void _checkChanges() {
    final profile = ref.read(profileProvider);
    bool hasChanges = false;
    
    // 텍스트 필드 변경 확인
    if (viewModel.nameController.text != profile.name ||
        viewModel.introductionController.text != profile.introduction ||
        viewModel.instagramIdController.text != profile.instagramId) {
      hasChanges = true;
    }
    
    // 이미지 변경 확인
    if (profile.profileImageFile != null) {
      hasChanges = true;
    }
    
    setState(() {
      _hasUnsavedChanges = hasChanges;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = ref.watch(profileEditingProvider);
    
    // WillPopScope 위젯으로 뒤로가기 이벤트 처리
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: isEditing
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      floating: false,
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
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () async {
                          final canPop = await _onWillPop();
                          if (canPop && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final success = await viewModel.saveProfile();
                            
                            if (success) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('프로필이 저장되었습니다.')),
                              );
                              Navigator.of(context).pop(true); // 결과 전달 (true = 업데이트 성공)
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('저장 중 오류가 발생했습니다.')),
                              );
                            }
                          },
                          child: const Text(
                            '저장',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ];
                },
                // 본문 내용
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 프로필 이미지
                      const ProfileImageWidget(),
                      const SizedBox(height: 20),
                      
                      // 이름 필드
                      ProfileTextField(
                        label: '이름',
                        controller: viewModel.nameController,
                        onChanged: (_) => _checkChanges(),
                      ),
                      const SizedBox(height: 20),
                      
                      // 소개글 필드
                      ProfileTextField(
                        label: '소개글',
                        controller: viewModel.introductionController,
                        maxLines: 3,
                        onChanged: (_) => _checkChanges(),
                      ),
                      const SizedBox(height: 20),
                      
                      // 인스타그램 ID 필드
                      ProfileTextField(
                        label: '인스타그램 ID',
                        controller: viewModel.instagramIdController,
                        onChanged: (_) => _checkChanges(),
                      ),
                      
                      // 키보드가 올라왔을 때를 위한 여유 공간
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}