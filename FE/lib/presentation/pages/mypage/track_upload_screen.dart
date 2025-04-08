import 'dart:io';
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:ari/providers/album/album_upload_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackUploadScreen extends ConsumerStatefulWidget {
  const TrackUploadScreen({super.key});

  @override
  ConsumerState<TrackUploadScreen> createState() => _TrackUploadScreenState();
}

class _TrackUploadScreenState extends ConsumerState<TrackUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trackTitleController = TextEditingController();
  final _lyricsController = TextEditingController();

  // 작곡가, 작사가 정보
  List<String> composers = [];
  List<String> lyricists = [];

  // 컨트롤러
  final _composerController = TextEditingController();
  final _lyricistController = TextEditingController();

  // 음원 파일
  File? audioFile;
  String? audioFileName;

  @override
  void dispose() {
    _trackTitleController.dispose();
    _lyricsController.dispose();
    _composerController.dispose();
    _lyricistController.dispose();
    super.dispose();
  }

  // 음원 파일 선택
  Future<void> _selectAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        audioFile = File(result.files.first.path!);
        audioFileName = result.files.first.name;
      });
    }
  }

  // 작곡가 추가
  void _addComposer() {
    if (_composerController.text.isNotEmpty) {
      setState(() {
        composers.add(_composerController.text);
        _composerController.clear();
      });
    }
  }

  // 작사가 추가
  void _addLyricist() {
    if (_lyricistController.text.isNotEmpty) {
      setState(() {
        lyricists.add(_lyricistController.text);
        _lyricistController.clear();
      });
    }
  }

  // 작곡가 제거
  void _removeComposer(int index) {
    setState(() {
      composers.removeAt(index);
    });
  }

  // 작사가 제거
  void _removeLyricist(int index) {
    setState(() {
      lyricists.removeAt(index);
    });
  }

  // 트랙 추가
  void _addTrack() {
    if (_formKey.currentState!.validate()) {
      if (audioFile == null) {
        context.showToast(
          '음원 파일을 선택해주세요',
          duration: const Duration(milliseconds: 1500),
        );
        return;
      }

      // ViewModel에 트랙 추가
      final trackData = {
        'trackTitle': _trackTitleController.text,
        'composers': composers,
        'lyricists': lyricists,
        'composer': composers.join(', '),
        'lyricist': lyricists.join(', '),
        'lyrics': _lyricsController.text,
        'audioFilePath': audioFile!.path,
        'audioFileName': audioFileName,
        'title': _trackTitleController.text,
      };

      ref.read(albumUploadViewModelProvider.notifier).addTrack(trackData);

      // 성공 메시지
      context.showToast(
        '트랙이 추가되었습니다',
        duration: const Duration(milliseconds: 1500),
      );

      // 앨범 업로드 화면으로 돌아가기
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              HeaderWidget(
                type: HeaderType.backWithTitle,
                title: "Track 업로드",
                onBackPressed: () => Navigator.pop(context),
              ),

              // 메인 컨텐츠
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 트랙명
                        const Text(
                          "트랙명",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _trackTitleController,
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
                            hintText: "트랙명을 입력하세요",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "트랙명을 입력해주세요";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // 가사
                        const Text(
                          "가사",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _lyricsController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 8,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "가사를 입력하세요",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 크레딧 - 작곡가
                        const Text(
                          "크레딧",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 작곡가 입력
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.mediumPurple,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 작곡가 목록 표시
                              Wrap(
                                spacing: 8,
                                children:
                                    composers.asMap().entries.map((entry) {
                                      return Chip(
                                        label: Text(
                                          entry.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: AppColors.darkPurple,
                                        deleteIconColor: Colors.white,
                                        onDeleted:
                                            () => _removeComposer(entry.key),
                                      );
                                    }).toList(),
                              ),

                              // 작곡가 추가 입력 필드
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _composerController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "작곡가 추가",
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: AppColors.mediumPurple,
                                    ),
                                    onPressed: _addComposer,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 작사가 입력
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.mediumPurple,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 작사가 목록 표시
                              Wrap(
                                spacing: 8,
                                children:
                                    lyricists.asMap().entries.map((entry) {
                                      return Chip(
                                        label: Text(
                                          entry.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: AppColors.darkPurple,
                                        deleteIconColor: Colors.white,
                                        onDeleted:
                                            () => _removeLyricist(entry.key),
                                      );
                                    }).toList(),
                              ),

                              // 작사가 추가 입력 필드
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _lyricistController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "작사가 추가",
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: AppColors.mediumPurple,
                                    ),
                                    onPressed: _addLyricist,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 음원 파일 선택
                        const Text(
                          "음원 파일",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectAudioFile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.mediumPurple,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    audioFileName ?? "음원 파일을 선택해주세요",
                                    style: TextStyle(
                                      color:
                                          audioFileName != null
                                              ? Colors.white
                                              : Colors.grey[400],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (audioFileName != null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        audioFile = null;
                                        audioFileName = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 트랙 등록 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addTrack,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "트랙 등록",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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
