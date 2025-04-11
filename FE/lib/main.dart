import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/widgets/common/global_bottom_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ari/data/models/track.dart';
import 'package:audio_session/audio_session.dart';
import 'package:ari/core/services/audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TrackAdapter());

  // ✅ audio_service 초기화
  final audioHandler = await initAudioService();

  // ✅ 오디오 세션 구성
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  // ✅ 인터럽션 처리
  session.interruptionEventStream.listen((event) async {
    if (event.begin) {
      if (event.type == AudioInterruptionType.pause ||
          event.type == AudioInterruptionType.duck) {
        await audioHandler.pause(); // ⚠️ 기존 handler 재사용
      }
    }
  });

  runApp(
    ProviderScope(
      overrides: [audioHandlerProvider.overrideWithValue(audioHandler)],
      child: const MyApp(),
    ),
  );
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
