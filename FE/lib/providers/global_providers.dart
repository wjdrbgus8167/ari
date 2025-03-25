import 'package:ari/presentation/viewmodels/sign_up_viewmodel.dart';
import 'package:ari/providers/chart/chart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/viewmodels/home_viewmodel.dart';
import '../presentation/viewmodels/listening_queue_viewmodel.dart';
import 'package:dio/dio.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

// Bottom Navigation 전역 상태
class BottomNavState extends StateNotifier<int> {
  BottomNavState() : super(0);
  void setIndex(int index) {
    state = index;
  }
}

final bottomNavProvider = StateNotifierProvider<BottomNavState, int>((ref) {
  return BottomNavState();
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  return HomeViewModel(getChartsUseCase: ref.watch(getChartsUseCaseProvider));
});

// ListeningQueueViewModel(재생목록) 전역 상태
final listeningQueueProvider =
    StateNotifierProvider<ListeningQueueViewModel, ListeningQueueState>(
      (ref) => ListeningQueueViewModel(),
    );

final signUpViewModelProvider =
    StateNotifierProvider<SignUpViewModel, SignUpState>(
      (ref) => SignUpViewModel(),
    );
