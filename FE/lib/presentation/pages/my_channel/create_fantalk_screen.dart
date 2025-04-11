import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../providers/my_channel/fantalk_providers.dart';
import '../../widgets/common/custom_toast.dart';
import '../../widgets/common/custom_dialog.dart';
import '../../routes/app_router.dart';

/// 팬톡 작성 화면
///
/// 아티스트 채널에서 팬톡을 작성하는 화면
/// 팬톡 내용 입력, 이미지 첨부(선택), 트랙 추천(선택) 기능을 제공
class CreateFantalkScreen extends ConsumerStatefulWidget {
  final String fantalkChannelId;

  /// [fantalkChannelId] : 팬톡 채널 ID
  const CreateFantalkScreen({super.key, required this.fantalkChannelId});

  @override
  ConsumerState<CreateFantalkScreen> createState() =>
      _CreateFantalkScreenState();
}

class _CreateFantalkScreenState extends ConsumerState<CreateFantalkScreen> {
  // 텍스트 컨트롤러
  final TextEditingController _contentController = TextEditingController();

  // 첨부 이미지 파일
  File? _selectedImage;

  // 업로드 중 상태
  bool _isUploading = false;

  // 최대 글자 수
  static const int maxContentLength = 1000;

  @override
  void initState() {
    super.initState();
    // 팬톡 작성 상태 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fantalkProvider.notifier).resetCreateState();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// 이미지 선택 함수
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
        // 선택한 이미지 경로를 상태에 저장
        ref.read(fantalkProvider.notifier).setSelectedImage(pickedImage.path);
      }
    } catch (e) {
      context.showToast('이미지를 불러오는데 실패했습니다');
    }
  }

  /// 트랙 선택 화면으로 이동
  Future<void> _navigateToTrackSelection() async {
    // 트랙 검색 화면으로 이동
    final result =
        await Navigator.of(context).pushNamed(AppRoutes.trackSelection)
            as Map<String, dynamic>?;

    // 선택된 트랙이 있는 경우
    if (result != null && result.containsKey('trackId')) {
      // 선택된 트랙 정보를 상태에 저장
      ref
          .read(fantalkProvider.notifier)
          .setSelectedTrack(
            trackId: result['trackId'],
            trackName: result['trackTitle'] ?? '',
            trackArtist: result['artist'] ?? '',
            trackCoverUrl: result['coverImageUrl'] ?? '',
          );
    }
  }

  /// 팬톡 등록 함수
  Future<void> _publishFantalk() async {
    // 내용이 비어있는지 체크
    if (_contentController.text.trim().isEmpty) {
      context.showToast('팬톡 내용을 입력해주세요');
      return;
    }

    // 글자수 제한 체크
    if (_contentController.text.length > maxContentLength) {
      context.showToast('최대 글자 수를 초과했습니다');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // 팬톡 등록 API 호출
      final success = await ref
          .read(fantalkProvider.notifier)
          .createFantalk(
            widget.fantalkChannelId,
            _contentController.text.trim(),
          );

      if (success) {
        if (mounted) {
          context.showToast('팬톡이 등록되었습니다');
          // 화면 닫기
          Navigator.of(context).pop(true); // 성공 결과 전달
        }
      } else {
        if (mounted) {
          context.showToast('팬톡 등록에 실패했습니다');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showToast('오류가 발생했습니다: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// 작성 취소 확인 다이얼로그
  Future<bool> _confirmCancel() async {
    // 내용이 비어있으면 바로 나가기
    if (_contentController.text.trim().isEmpty &&
        !ref.read(fantalkProvider).hasSelectedImage &&
        !ref.read(fantalkProvider).hasSelectedTrack) {
      return true;
    }

    // 내용이 있으면 확인 다이얼로그 표시
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('작성 취소', style: TextStyle(color: Colors.white)),
            content: const Text(
              '작성 중인 내용이 있습니다. 정말 취소하시겠습니까?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // 취소
                child: const Text(
                  '계속 작성',
                  style: TextStyle(color: AppColors.mediumPurple),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // 확인
                child: Text('취소', style: TextStyle(color: Colors.red[300])),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // 팬톡 상태 가져오기
    final fantalkState = ref.watch(fantalkProvider);

    // 텍스트 길이 계산
    final currentLength = _contentController.text.length;
    final isLengthExceeded = currentLength > maxContentLength;

    // 선택된 이미지와 트랙 정보
    final selectedImage =
        _selectedImage ??
        (fantalkState.selectedImagePath != null
            ? File(fantalkState.selectedImagePath!)
            : null);

    final hasSelectedTrack = fantalkState.hasSelectedTrack;
    final selectedTrackName = fantalkState.selectedTrackName;
    final selectedTrackArtist = fantalkState.selectedTrackArtist;
    final selectedTrackCoverUrl = fantalkState.selectedTrackCoverUrl;

    return WillPopScope(
      onWillPop: _confirmCancel,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            '팬톡 작성',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              final canCancel = await _confirmCancel();
              if (canCancel && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            // 게시 버튼
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child:
                  _isUploading
                      ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.mediumPurple,
                            strokeWidth: 2.0,
                          ),
                        ),
                      )
                      : TextButton(
                        onPressed: isLengthExceeded ? null : _publishFantalk,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mediumPurple,
                          disabledForegroundColor: Colors.grey,
                        ),
                        child: const Text(
                          '게시',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 내용 입력 영역
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isLengthExceeded
                              ? Colors.red
                              : AppColors.mediumPurple.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _contentController,
                    maxLines: 10,
                    minLines: 5,
                    maxLength: maxContentLength + 50, // 경고를 위해 여유 글자수 추가
                    onChanged: (_) => setState(() {}), // 텍스트 변경 시 화면 갱신
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: '팬들과 나누고 싶은 이야기를 적어보세요...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      counterText: '', // 기본 카운터 텍스트 숨기기
                    ),
                  ),
                ),

                // 글자 수 표시
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    '$currentLength / $maxContentLength',
                    style: TextStyle(
                      color: isLengthExceeded ? Colors.red : Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ),

                // 글자 수 초과 시 경고 메시지
                if (isLengthExceeded)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      '최대 글자 수를 초과했습니다.',
                      style: TextStyle(color: Colors.red[300], fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 24),

                // 이미지 첨부 영역
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지 첨부 버튼
                      ListTile(
                        leading: const Icon(
                          Icons.image,
                          color: AppColors.mediumPurple,
                        ),
                        title: const Text(
                          '이미지 첨부',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '팬톡에 이미지를 첨부합니다 (선택사항)',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.mediumPurple,
                          ),
                          onPressed: _isUploading ? null : _pickImage,
                        ),
                      ),

                      // 선택된 이미지 미리보기
                      if (selectedImage != null) ...[
                        const Divider(color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImage,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // 이미지 제거 버튼
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap:
                                      _isUploading
                                          ? null
                                          : () {
                                            setState(() {
                                              _selectedImage = null;
                                            });
                                            // 상태에서도 이미지 제거
                                            ref
                                                .read(fantalkProvider.notifier)
                                                .clearSelectedImage();
                                          },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 트랙 추가 영역
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 트랙 추가 버튼
                      ListTile(
                        leading: const Icon(
                          Icons.music_note,
                          color: AppColors.mediumPurple,
                        ),
                        title: const Text(
                          '트랙 추가',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '팬톡에 추천하고 싶은 트랙을 추가합니다 (선택사항)',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.mediumPurple,
                          ),
                          onPressed:
                              _isUploading ? null : _navigateToTrackSelection,
                        ),
                      ),

                      // 선택된 트랙 표시
                      if (hasSelectedTrack) ...[
                        const Divider(color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // 트랙 커버 이미지
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      selectedTrackCoverUrl ?? '',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // 트랙 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 트랙 제목
                                    Text(
                                      selectedTrackName ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // 아티스트 이름
                                    Text(
                                      selectedTrackArtist ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 삭제 버튼
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed:
                                    _isUploading
                                        ? null
                                        : () {
                                          // 선택된 트랙 제거
                                          ref
                                              .read(fantalkProvider.notifier)
                                              .clearSelectedTrack();
                                        },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
