import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../providers/my_channel/my_channel_providers.dart';
import '../../../presentation/viewmodels/my_channel_viewmodel.dart';
import '../../widgets/common/custom_toast.dart';

/// 아티스트 공지사항 작성 화면
///
/// 아티스트가 새 공지사항을 작성하는 화면입니다.
/// 공지사항 내용 입력과 이미지 첨부(선택 사항) 기능을 제공합니다.
class CreateNoticeScreen extends ConsumerStatefulWidget {
  final String memberId;

  /// [memberId] : 공지사항 작성 아티스트 ID
  const CreateNoticeScreen({super.key, required this.memberId});

  @override
  ConsumerState<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends ConsumerState<CreateNoticeScreen> {
  // 텍스트 컨트롤러
  final TextEditingController _contentController = TextEditingController();

  // 첨부 이미지 파일
  File? _selectedImage;

  // 업로드 중 상태
  bool _isUploading = false;

  // 최대 글자 수
  static const int maxContentLength = 1000;

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
      }
    } catch (e) {
      context.showToast('이미지를 불러오는데 실패했습니다');
    }
  }

  /// 공지사항 게시 함수
  Future<void> _publishNotice() async {
    // 내용이 비어있는지 체크
    if (_contentController.text.trim().isEmpty) {
      context.showToast('공지사항 내용을 입력해주세요');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // 이미지 파일 준비
      MultipartFile? noticeImage;
      if (_selectedImage != null) {
        String fileName = _selectedImage!.path.split('/').last;
        noticeImage = await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: fileName,
        );
      }

      // 공지사항 작성 API 호출
      final success = await ref
          .read(myChannelProvider.notifier)
          .createArtistNotice(
            _contentController.text.trim(),
            noticeImage: noticeImage,
          );

      if (success) {
        // 성공 시 마이 채널 화면으로 돌아가기 전에 공지사항 목록 갱신
        await ref
            .read(myChannelProvider.notifier)
            .loadArtistNotices(widget.memberId);

        if (mounted) {
          context.showToast('공지사항이 등록되었습니다');
          // 화면 닫기
          Navigator.of(context).pop(true); // 성공 결과 전달
        }
      } else {
        if (mounted) {
          context.showToast('공지사항 등록에 실패했습니다');
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
    if (_contentController.text.trim().isEmpty && _selectedImage == null) {
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
    // 텍스트 길이 계산
    final currentLength = _contentController.text.length;
    final isLengthExceeded = currentLength > maxContentLength;

    return WillPopScope(
      onWillPop: _confirmCancel,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            '공지사항 작성',
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
                        onPressed: isLengthExceeded ? null : _publishNotice,
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
                      hintText: '팬들에게 전할 소식을 공유해보세요...',
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
                          '공지사항에 이미지를 첨부합니다 (선택사항)',
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
                      if (_selectedImage != null) ...[
                        const Divider(color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
