import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/home/home_screen.dart';
import 'presentation/widgets/common/global_bottom_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ari/data/models/track.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive 초기화
  await Hive.initFlutter();
  // Hive 어댑터 등록 (Track 모델에 대한 TypeAdapter)
  Hive.registerAdapter(TrackAdapter());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Ari',
      theme: ThemeData.dark(),
      home: const GlobalNavigationContainer(),
      onGenerateRoute: (settings) => AppRouter.generateRoute(settings, ref),
    );
  }
}
