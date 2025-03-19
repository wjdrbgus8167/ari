import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/home/home_screen.dart';
import 'presentation/widgets/common/global_bottom_widget.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ari',
      theme: ThemeData.dark(),
      home: const GlobalBottomWidget(child: HomeScreen()),
      // 네임드 라우트
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
