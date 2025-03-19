import 'package:flutter/material.dart';
import '../../widgets/common/header_widget.dart';
import '../../widgets/common/button_large.dart';

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
                  // 기본 버튼
                  ButtonLarge(
                    text: '트랙 등록',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('기본 버튼 클릭!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16), // 버튼 간격
                  // 보라색 테두리 버튼
                  ButtonLarge(
                    text: '작곡 추가',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('보라색 테두리 버튼 클릭!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                    borderColor: const Color(0xFF6C38F8), // 보라색 테두리
                    borderWidth: 2.0,
                  ),

                  const SizedBox(height: 16), // 버튼 간격
                  // PrimaryButtonLarge 가져다 쓰기
                  PrimaryButtonLarge(
                    text: '커스텀 버튼',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('커스텀 버튼 클릭!'),
                          duration: Duration(seconds: 1),
                        ),
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
