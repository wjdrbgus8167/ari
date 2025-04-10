// presentation/pages/mypage/edit_profile_screen.dart
import 'package:ari/presentation/pages/mypage/mypage_screen.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/mypage/edit_profile_viewmodel.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:ari/presentation/widgets/mypage/profile_image_widget.dart';
import 'package:ari/presentation/widgets/mypage/profile_input_field.dart';
import 'package:ari/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final ProfileEditViewModel viewModel;
  bool _hasUnsavedChanges = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    viewModel = ref.read(profileEditViewModelProvider);
    print('initState 호출됨');
    
    // 프로필 로드 및 컨트롤러 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoading = true);
      await viewModel.loadProfile(); // 이 메서드에서 컨트롤러 초기화까지 수행
      setState(() => _isLoading = false);
    });
    print('initState 호출됨');
  }

  @override
  void dispose() {
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
                            print('저장 버튼 클릭됨 - 시작');
                            
                            // 먼저 필요한 context 정보 저장
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            
                            if (!mounted) return;
                            
                            setState(() {
                              _isLoading = true;
                              print('로딩 상태로 변경');
                            });
                            
                            try {
                              print('saveProfile 호출 전');
                              // 프로필 저장 API 호출
                              final success = await viewModel.saveProfile();
                              print('saveProfile 호출 후: $success');
                              
                              // 비동기 작업 후 위젯이 여전히 마운트되어 있는지 확인
                              if (!mounted) {
                                print('API 호출 후 위젯이 마운트되지 않음');
                                return;
                              }
                              
                              // 모든 비동기 작업 완료 후 상태 업데이트
                              setState(() {
                                _isLoading = false;
                                print('로딩 상태 해제');
                              });
                              
                              if (success) {
                                print('성공 분기 진입');
                                // 토스트 메시지 표시
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text('프로필이 저장되었습니다'), duration: Duration(seconds: 1))
                                );
                                
                                // 비동기 작업 완료 후 화면 전환
                                await Future.delayed(const Duration(milliseconds: 300));
                                
                                // 화면 전환 전 마운트 상태 재확인
                                if (mounted) {
                                  print('네비게이션 시작');
                                  navigator.pushReplacementNamed(AppRoutes.myPage);
                                  print('네비게이션 완료');
                                }
                              } else {
                                print('실패 분기 진입');
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text('저장 중 오류가 발생했습니다'), duration: Duration(seconds: 1))
                                );
                              }
                            } catch (e) {
                              print('예외 발생: ${e.toString()}');
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}'), duration: Duration(seconds: 1))
                                );
                              }
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