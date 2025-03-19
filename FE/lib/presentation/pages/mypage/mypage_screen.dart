import 'package:flutter/material.dart';
import '../../widgets/common/header_widget.dart';

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
          ],
        ),
      ),
    );
  }
}