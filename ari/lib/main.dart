import 'package:flutter/material.dart';
import '../presentation/pages/home/home_screen.dart'; // 홈 스크린이 정의된 파일

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Platform Mock',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        // 필요한 경우 Material 3 설정 등 추가 가능
      ),
      home: HomeScreen(), // 앱 시작 시 보여줄 화면
      // 라우트 등을 추가할 수 있습니다.
    );
  }
}
