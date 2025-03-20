import 'package:flutter/material.dart';
import '../../widgets/common/header_widget.dart';
import '../../widgets/common/button_large.dart';
import '../../widgets/common/custom_dialog.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 뒤로가기 있는 헤더
            HeaderWidget(
              type: HeaderType.backWithTitle,
              title: "마이페이지",
              onBackPressed: () => Navigator.of(context).pop(),
            ),

            const Expanded(
              child: Center(
                child: Text(
                  "마이 페이지",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 여기서부터 버튼 테스트 중
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 기본 버튼, 여기서 showAlertDialog 사용
                  ButtonLarge(
                    text: '트랙 등록',
                    onPressed: () {
                      // 스낵바 대신 Alert 다이얼로그 표시
                      context.showAlertDialog(
                        title: '알림',
                        content: '새로운 트랙을 등록하시겠습니까?',
                        confirmText: '확인',
                        confirmButtonColor: Colors.blue,
                        onConfirm: () {
                          // 확인 버튼 클릭 시 실행될 코드
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('트랙 등록 진행 중...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16), // 버튼 간격
                  // 보라색 테두리 버튼 - showConfirmDialog 사용 (확인/취소 버튼이 있는 다이얼로그)
                  ButtonLarge(
                    text: '작곡 추가',
                    onPressed: () {
                      // 스낵바 대신 Confirm 다이얼로그 표시
                      context.showConfirmDialog(
                        title: '작곡 추가',
                        content: '새로운 작곡을 추가하시겠습니까?\n추가 후에는 수정이 제한될 수 있습니다.',
                        confirmText: '추가하기',
                        cancelText: '취소',
                        confirmButtonColor: const Color(0xFF6C38F8), // 보라색 버튼
                        cancelButtonColor: Colors.grey,
                        onConfirm: () {
                          // 확인 버튼 클릭 시 실행될 코드
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('작곡 추가가 진행됩니다.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        onCancel: () {
                          // 취소 버튼 클릭 시 실행될 코드
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('작곡 추가가 취소되었습니다.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                    borderColor: const Color(0xFF6C38F8), // 보라색 테두리
                    borderWidth: 2.0,
                  ),
                  const SizedBox(height: 16), // 버튼 간격
                  // PrimaryButtonLarge - showCustomDialog 사용 (커스텀 내용이 있는 다이얼로그)
                  PrimaryButtonLarge(
                    text: '커스텀 버튼',
                    onPressed: () {
                      // 스낵바 대신 Custom 다이얼로그 표시
                      context.showCustomDialog(
                        title: '음악 정보',
                        customContent: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.music_note,
                                size: 60,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '곡 제목: Summer Vibe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '아티스트: DJ Cloud',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '발매일: 2025-03-15',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const Icon(
                                  Icons.star_half,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4.5',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                        confirmText: '재생하기',
                        cancelText: '닫기',
                        confirmButtonColor: Colors.green,
                        onConfirm: () {
                          // 확인 버튼 클릭 시 실행될 코드
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('음악 재생을 시작합니다.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
