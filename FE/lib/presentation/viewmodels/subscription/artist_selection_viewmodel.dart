// subscription_view_model.dart
import 'package:ari/data/models/my_channel/neighbor.dart';
import 'package:ari/domain/usecases/my_channel/my_channel_usecases.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:ari/providers/my_channel/my_channel_providers.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 아티스트 정보
class ArtistInfo {
  final int id;
  final String name;
  final int followerCount;
  final int subscriberCount;
  final bool isSubscribed;
  final String? imageUrl;
  final bool isChecked;

  ArtistInfo({
    required this.id,
    required this.name,
    required this.followerCount,
    required this.subscriberCount,
    required this.isSubscribed,
    required this.isChecked,
    this.imageUrl,
  });

  // 포맷된 팔로워 수 문자열 반환
  String get followers {
    if (followerCount >= 1000) {
      return '${(followerCount / 1000).toStringAsFixed(1)}K Followers';
    }
    return '$followerCount Followers';
  }

  // 포맷된 구독자 수 문자열 반환
  String get subscribers {
    if (subscriberCount >= 10000) {
      return '구독자 ${(subscriberCount / 10000).toStringAsFixed(1)}만명';
    } else if (subscriberCount >= 1000) {
      return '구독자 ${(subscriberCount / 1000).toStringAsFixed(1)}천명';
    }
    return '구독자 $subscriberCount명';
  }

  ArtistInfo copyWith({
    int? id,
    String? name,
    int? followerCount,
    int? subscriberCount,
    bool? isSubscribed,
    bool? isChecked,
    String? imageUrl,
  }) {
    return ArtistInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      followerCount: followerCount ?? this.followerCount,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isChecked: isChecked ?? this.isChecked,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Neighbor 모델로부터 ArtistInfo 객체 생성
  factory ArtistInfo.fromNeighbor(Neighbor neighbor) {
    return ArtistInfo(
      id: neighbor.memberId,
      name: neighbor.memberName,
      followerCount: neighbor.followerCount,
      subscriberCount: neighbor.subscriberCount,
      isSubscribed: neighbor.subscribeYn,
      isChecked: false, // 초기에는 모두 선택 안 됨
      imageUrl: neighbor.profileImageUrl,
    );
  }
}

// 구독 상태 모델
class ArtistInfoState {
  final List<ArtistInfo> artistInfos;
  final bool isLoading;
  final String? error;
  final int followingCount;

  const ArtistInfoState({
    required this.artistInfos,
    this.isLoading = false,
    this.error,
    this.followingCount = 0,
  });

  ArtistInfoState copyWith({
    List<ArtistInfo>? artistInfos,
    bool? isLoading,
    String? error,
    int? followingCount,
  }) {
    return ArtistInfoState(
      artistInfos: artistInfos ?? this.artistInfos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}

// 구독 상태 관리를 위한 StateNotifier
class ArtistInfoNotifier extends StateNotifier<ArtistInfoState> {
  final GetFollowingsUseCase getFollowingsUseCase;
  final String? userId;

  ArtistInfoNotifier({
    required this.getFollowingsUseCase,
    required this.userId,
  }) : super(const ArtistInfoState(artistInfos: [])) {
    loadArtistInfos();
  }

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

  // API를 호출하여 아티스트 정보 로드
  Future<void> loadArtistInfos() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await getFollowingsUseCase.execute(userId ?? '1');
      
      // API 응답 처리
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (followingResponse) {
          // FollowingResponse 객체에서 필요한 정보 추출
          final List<ArtistInfo> artistInfos = followingResponse.followings
              .map((neighbor) => ArtistInfo.fromNeighbor(neighbor))
              .toList();
          
          state = state.copyWith(
            artistInfos: artistInfos,
            followingCount: followingResponse.followingCount,
            isLoading: false,
          );
        },
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
  return ArtistInfoNotifier(
    getFollowingsUseCase: ref.watch(getFollowingsUseCaseProvider),
    userId: ref.watch(userIdProvider), // 사용자 ID를 가져옵니다.
  );
});