// subscription_view_model.dart
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 아티스트 정보
class ArtistInfo {
  final int id;
  final String name;
  final String followers;
  final String subscribers;
  final bool isSubscribed;
  final String? imageUrl;
  final bool isChecked;

  ArtistInfo({
    required this.id,
    required this.name,
    required this.followers,
    required this.subscribers,
    required this.isSubscribed,
    required this.isChecked,
    this.imageUrl,
  });

  ArtistInfo copyWith({
    int? id,
    String? name,
    String? followers,
    String? subscribers,
    bool? isSubscribed,
    bool? isChecked,
    String? imageUrl,

  }) {
    return ArtistInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      followers: followers ?? this.followers,
      subscribers: subscribers ?? this.subscribers,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isChecked: isChecked ?? this.isChecked,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// 구독 상태 모델
class ArtistInfoState {
  final List<ArtistInfo> artistInfos;
  final bool isLoading;
  final String? error;

  const ArtistInfoState({
    required this.artistInfos,
    this.isLoading = false,
    this.error,
  });

  ArtistInfoState copyWith({
    List<ArtistInfo>? artistInfos,
    bool? isLoading,
    String? error,
  }) {
    return ArtistInfoState(
      artistInfos: artistInfos ?? this.artistInfos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// 구독 상태 관리를 위한 StateNotifier
class ArtistInfoNotifier extends StateNotifier<ArtistInfoState> {
  ArtistInfoNotifier() : super(ArtistInfoState(
    artistInfos: [
      ArtistInfo(
        id: 1,
        name: 'Yellow',
        followers: '4.3K Followers',
        subscribers: '구독자 4.2만명',
        isSubscribed: false,
        isChecked: false,
      ),
      ArtistInfo(
        id: 2,
        name: 'Yellow',
        followers: '4.3K Followers',
        subscribers: '구독자 4.2만명',
        isSubscribed: false,
        isChecked: false,
      ),
      ArtistInfo(
        id: 3,
        name: 'Yellow',
        followers: '4.3K Followers',
        subscribers: '구독자 4.2만명',
        isSubscribed: false,
        isChecked: false,
      ),
      ArtistInfo(
        id: 4,
        name: 'Yellow',
        followers: '4.3K Followers',
        subscribers: '구독자 4.2만명',
        isSubscribed: true,
        isChecked: false,
        imageUrl: null,
      ),
      ArtistInfo(
        id: 5,
        name: 'Yellow',
        followers: '4.3K Followers',
        subscribers: '구독자 4.2만명',
        isSubscribed: true,
        isChecked: false,
        imageUrl: null,
      ),
    ],
  ));

  // 체크 상태 토글 (단일 선택만 가능하도록 수정)
  void toggleCheck(int id) {
    // 현재 선택된 아티스트의 체크 상태 확인
    final selectedArtist = state.artistInfos.firstWhere((artist) => artist.id == id);
    final willBeChecked = !selectedArtist.isChecked;
    
    state = state.copyWith(
      artistInfos: state.artistInfos.map((artistInfo) {
        // 구독 중인 아티스트는 체크 대상에서 제외
        if (artistInfo.isSubscribed) {
          return artistInfo;
        }
        
        // 선택한 아티스트인 경우
        if (artistInfo.id == id) {
          // 체크 상태 토글
          return artistInfo.copyWith(
            isChecked: willBeChecked,
          );
        } 
        // 다른 모든 아티스트들
        else {
          // 새로 선택한 항목이 체크될 경우, 다른 모든 항목은 체크 해제
          if (willBeChecked) {
            return artistInfo.copyWith(
              isChecked: false,
            );
          }
          // 체크 해제되는 경우에는 다른 항목 상태 유지
          return artistInfo;
        }
      }).toList(),
    );
  }
  // 선택 완료 처리 (체크된 아티스트를 찾아서 전달)
  Future<void> navigateToSubscriptionPage(BuildContext context) async {
    // 체크된 아티스트 찾기
    final checkedArtists = state.artistInfos.where((artist) => artist.isChecked).toList();

    // 체크된 아티스트가 없으면 알림 표시 후 진행 중단
    if (checkedArtists.isEmpty) {
      // 스낵바 또는 다이얼로그로 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구독할 아티스트를 선택해주세요.'),
          duration: Duration(seconds: 2),
        ),
      );
      return; // 함수 종료, 더 이상 진행하지 않음
    }
    
    // 구독 타입은 무조건 아티스트 구독으로 설정
    const subscriptionType = SubscriptionType.artist;
    
    // 구독 페이지로 이동
    Navigator.pushNamed(
      context, 
      AppRoutes.subscriptionPayment,
      arguments: {
        'subscriptionType': subscriptionType,
        'artistInfo': checkedArtists[0],
      },
    );
  }

  // 구독 목록 초기 로드 (실제 환경에서는 API 호출 등으로 구현)
  Future<void> loadArtistInfos() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // API 호출 등의 비동기 작업을 수행하는 로직을 여기에 구현하세요.
      // 예시 코드는 2초 지연 후 상태 업데이트
      await Future.delayed(const Duration(seconds: 2));
      
      // 상태 업데이트 (실제로는 API 응답으로 받은 데이터로 업데이트)
      state = state.copyWith(
        isLoading: false,
        // subscriptions: 여기에 실제 데이터를 설정하세요.
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Riverpod 프로바이더
final artistInfoProvider = StateNotifierProvider<ArtistInfoNotifier, ArtistInfoState>((ref) {
  return ArtistInfoNotifier();
});