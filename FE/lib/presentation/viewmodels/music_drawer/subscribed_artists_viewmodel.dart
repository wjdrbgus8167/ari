import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/models/music_drawer/subscribed_artist_model.dart';
import 'package:ari/domain/usecases/music_drawer/subscribed_artists_usecases.dart';

/// 구독 중인 아티스트 상태
class SubscribedArtistsState {
  final List<SubscribedArtistModel> artists;
  final bool isLoading;
  final String? errorMessage;

  SubscribedArtistsState({
    this.artists = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  /// 새로운 상태 생성
  SubscribedArtistsState copyWith({
    List<SubscribedArtistModel>? artists,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SubscribedArtistsState(
      artists: artists ?? this.artists,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// 초기 로딩 상태
  factory SubscribedArtistsState.loading() {
    return SubscribedArtistsState(isLoading: true);
  }

  /// 에러 상태
  factory SubscribedArtistsState.error(String message) {
    return SubscribedArtistsState(errorMessage: message);
  }
}

/// 구독 중인 아티스트 뷰모델
class SubscribedArtistsViewModel extends StateNotifier<SubscribedArtistsState> {
  final GetSubscribedArtistsUseCase _getSubscribedArtistsUseCase;
  final GetSubscribedArtistsCountUseCase _getSubscribedArtistsCountUseCase;

  SubscribedArtistsViewModel(
    this._getSubscribedArtistsUseCase,
    this._getSubscribedArtistsCountUseCase,
  ) : super(SubscribedArtistsState()) {
    // 초기 데이터 로드
    loadSubscribedArtists();
  }

  /// 구독 중인 아티스트 목록 로드
  Future<void> loadSubscribedArtists() async {
    try {
      state = SubscribedArtistsState.loading();

      final artists = await _getSubscribedArtistsUseCase.execute();

      state = state.copyWith(artists: artists, isLoading: false);
    } catch (e) {
      state = SubscribedArtistsState.error(e.toString());
    }
  }

  /// 구독 중인 아티스트 수 조회
  Future<int> getSubscribedArtistsCount() async {
    try {
      return await _getSubscribedArtistsCountUseCase.execute();
    } catch (e) {
      debugPrint('아티스트 수 조회 에러: $e');
      return 0;
    }
  }
}
