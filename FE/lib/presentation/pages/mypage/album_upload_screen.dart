import 'dart:io';
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/mypage/album_upload_viewmodel.dart';
import 'package:ari/presentation/widgets/common/custom_dialog.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/providers/album/album_upload_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ari/providers/user_provider.dart';

class AlbumUploadScreen extends ConsumerStatefulWidget {
  const AlbumUploadScreen({super.key});

  @override
  ConsumerState<AlbumUploadScreen> createState() => _AlbumUploadScreenState();
}

class _AlbumUploadScreenState extends ConsumerState<AlbumUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _albumTitleController = TextEditingController();
  final _albumDescriptionController = TextEditingController();

  // 앨범 장르 목록
  final List<String> genres = ['힙합', '재즈', '밴드', '알앤비', '어쿠스틱'];
  String selectedGenre = '';

  @override
  void dispose() {
    _albumTitleController.dispose();
    _albumDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // 상태가 있는 경우 컨트롤러에 값 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 로그인 상태 확인
      final isLoggedIn = ref.read(isUserLoggedInProvider);

      if (!isLoggedIn) {
        // 로그인되지 않은 경우, custom 다이얼로그 사용하여 로그인 화면으로 이동
        context.showCustomDialog(
          title: "로그인 필요",
          content: "앨범 업로드는 로그인이 필요한 기능입니다.",
          singleButtonMode: true,
          confirmText: "로그인",
          confirmButtonColor: AppColors.mediumPurple,
          onConfirm: () {
            // 다이얼로그가 닫힌 후 로그인 페이지로 이동하기 위해 지연 실행
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            });
          },
        );

        final state = ref.read(albumUploadViewModelProvider);
        if (state.albumTitle.isNotEmpty) {
          _albumTitleController.text = state.albumTitle;
        }
        if (state.albumDescription.isNotEmpty) {
          _albumDescriptionController.text = state.albumDescription;
        }
        if (state.selectedGenre.isNotEmpty) {
          setState(() {
            selectedGenre = state.selectedGenre;
          });
        }
      }
    });
  }

  // 앨범 커버 이미지 선택
  Future<void> _selectCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final viewModel = ref.read(albumUploadViewModelProvider.notifier);
      viewModel.setCoverImageFile(File(image.path));
    }
  }

  // 트랙 추가 화면으로 이동
  void _navigateToAddTrack() {
    // 현재 앨범 상태를 저장
    final viewModel = ref.read(albumUploadViewModelProvider.notifier);
    viewModel.setAlbumTitle(_albumTitleController.text);
    viewModel.setAlbumDescription(_albumDescriptionController.text);
    viewModel.setSelectedGenre(selectedGenre);

    // 트랙 추가 화면으로 이동
    Navigator.pushNamed(context, AppRoutes.trackUpload);
  }

  // 앨범 업로드 요청
  Future<void> _uploadAlbum() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = ref.read(albumUploadViewModelProvider.notifier);

      // 앨범 정보 업데이트
      viewModel.setAlbumTitle(_albumTitleController.text);
      viewModel.setAlbumDescription(_albumDescriptionController.text);
      viewModel.setSelectedGenre(selectedGenre);

      // 업로드 진행
      await viewModel.uploadAlbum();

      final state = ref.read(albumUploadViewModelProvider);
      print("업로드 후 상태: ${state.status}");

      if (state.status == AlbumUploadStatus.success && mounted) {
        // 업로드 성공 시 다이얼로그 표시
        await context.showCustomDialog(
          title: "업로드 성공",
          content: "앨범이 성공적으로 업로드되었습니다.\n이동할 페이지를 선택해주세요.",
          confirmText: "My Channel",
          cancelText: "My Page",
          confirmButtonColor: AppColors.mediumPurple,
          cancelButtonColor: AppColors.darkPurple,
          onConfirm: () {
            // 다이얼로그가 닫힌 후 네비게이션 실행하기 위해 지연 처리
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // 나의 채널로 이동
              Navigator.of(
                context,
              ).popUntil((route) => route.settings.name == AppRoutes.home);
              Navigator.of(context).pushNamed(AppRoutes.myChannel);
              // 상태 초기화
              viewModel.resetForm();
            });
          },
          onCancel: () {
            // 다이얼로그가 닫힌 후 네비게이션 실행하기 위해 지연 처리
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // 마이페이지로 이동
              Navigator.of(
                context,
              ).popUntil((route) => route.settings.name == AppRoutes.home);
              Navigator.of(context).pushNamed(AppRoutes.myPage);
              // 상태 초기화
              viewModel.resetForm();
            });
          },
        );
      } else if (state.status == AlbumUploadStatus.error && mounted) {
        // 실패 시 에러 다이얼로그 표시
        context.showCustomDialog(
          title: "업로드 실패",
          content: state.errorMessage ?? "알 수 없는 오류가 발생했습니다.",
          singleButtonMode: true,
          confirmButtonColor: Colors.red,
        );
      }
    }
  }

  // 업로드 버튼 또는 진행률 UI 빌드
  Widget _buildUploadButton() {
    final state = ref.watch(albumUploadViewModelProvider);

    if (state.status == AlbumUploadStatus.loading) {
      // 로딩 상태일 때 진행률 표시
      return Column(
        children: [
          // 진행률 표시 (%)
          Text(
            '업로드 중... ${(state.uploadProgress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // 진행 상태 바
          LinearProgressIndicator(
            value: state.uploadProgress,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.mediumPurple),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 16),
        ],
      );
    } else {
      // 기존 업로드 버튼
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              state.isFormValid && state.status != AlbumUploadStatus.loading
                  ? _uploadAlbum
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          child: const Text(
            "앨범 등록",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(albumUploadViewModelProvider);

    // 버튼 활성화 조건 확인
    bool isFormValid =
        state.selectedGenre.isNotEmpty &&
        _albumTitleController.text.isNotEmpty &&
        state.coverImageFile != null &&
        state.tracks.isNotEmpty;

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              HeaderWidget(
                type: HeaderType.backWithTitle,
                title: "앨범 업로드",
                onBackPressed: () => Navigator.pop(context),
              ),

              // 로딩 인디케이터 (기존 코드는 제거)
              // if (state.status == AlbumUploadStatus.loading)
              //   const LinearProgressIndicator(color: AppColors.mediumPurple),

              // 메인 컨텐츠
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 앨범 커버 이미지 선택
                        Center(
                          child: GestureDetector(
                            onTap: _selectCoverImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                                image:
                                    state.coverImageFile != null
                                        ? DecorationImage(
                                          image: FileImage(
                                            state.coverImageFile!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  state.coverImageFile == null
                                      ? const Icon(
                                        Icons.add_photo_alternate,
                                        size: 40,
                                        color: Colors.grey,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 장르 선택
                        const Text(
                          "장르",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 장르 선택 버튼 그룹
                        Wrap(
                          spacing: 8.0,
                          children:
                              genres.map((genre) {
                                final isSelected = selectedGenre == genre;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedGenre = genre;
                                    });
                                    ref
                                        .read(
                                          albumUploadViewModelProvider.notifier,
                                        )
                                        .setSelectedGenre(genre);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? AppColors.mediumPurple
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? AppColors.mediumPurple
                                                : Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      genre,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.white,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // 앨범명
                        const Text(
                          "앨범명",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _albumTitleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: false,
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.mediumPurple,
                              ),
                            ),
                            hintText: "앨범명을 입력하세요",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "앨범명을 입력해주세요";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // 앨범 설명
                        const Text(
                          "앨범 설명",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _albumDescriptionController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 4,
                          decoration: InputDecoration(
                            filled: false,
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.mediumPurple,
                              ),
                            ),
                            hintText: "앨범에 대한 설명을 입력하세요",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "앨범 설명을 입력해주세요";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // 트랙 목록
                        const Text(
                          "Track",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 추가된 트랙 목록 표시
                        if (state.tracks.isNotEmpty)
                          ...state.tracks.asMap().entries.map((entry) {
                            final index = entry.key;
                            final track = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          track['trackTitle'] ?? '제목 없음',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '작곡: ${track['composer'] ?? '미지정'} | 작사: ${track['lyricist'] ?? '미지정'}',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(
                                            albumUploadViewModelProvider
                                                .notifier,
                                          )
                                          .removeTrack(index);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),

                        // 트랙 추가 버튼
                        InkWell(
                          onTap: _navigateToAddTrack,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.mediumPurple,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: AppColors.mediumPurple),
                                SizedBox(width: 8),
                                Text(
                                  "추가하기",
                                  style: TextStyle(
                                    color: AppColors.mediumPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 앨범 등록 버튼 (새로운 진행률 UI로 대체)
                        _buildUploadButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
