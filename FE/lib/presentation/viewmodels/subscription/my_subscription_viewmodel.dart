import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/core/constants/contract_constants.dart';
import 'package:ari/core/services/wallet_service.dart';
import 'package:ari/data/datasources/subscription/subscription_datasources.dart';
import 'package:ari/data/models/subscription/my_subscription_model.dart';
import 'package:ari/data/repositories/subscription_repository.dart';
import 'package:ari/domain/repositories/subscription/subscription_repository.dart';
import 'package:ari/domain/usecases/subscription/my_subscription_usecase.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/providers/subscription/walletServiceProviders.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // UUID 패키지 추가 필요
import 'dart:developer' as dev; // 디버깅 로그를 위한 패키지

// MySubscriptionModel에 확장 메서드 추가
extension MySubscriptionModelExtension on MySubscriptionModel {
  // API 응답 모델을 UI 상태 모델로 변환
  SubscriptionState toSubscriptionState() {
    // UUID 생성기
    final uuid = Uuid();
    
    // 월간 구독도 리스트로 처리
    final monthlySubscriptionList = monthly.map((month) {
      return MonthlySubscription(
        id: uuid.v4(), // 고유 식별자 생성
        price: month.price,
        subscribedAt: month.subscribeAt,
        expiredAt: month.expiredAt ?? '', // null 처리
      );
    }).toList();

    // 아티스트 구독에 UUID 식별자 추가
    final artistSubscriptionList = artists.map((artist) {
      return ArtistSubscription(
        id: uuid.v4(), // 고유 식별자 생성
        artistNickname: artist.artistNickname,
        price: artist.price,
        subscribedAt: artist.subscribeAt,
        expiredAt: artist.expiredAt ?? '',
      );
    }).toList();

    return SubscriptionState(
      monthlySubscriptions: monthlySubscriptionList,
      artistSubscriptions: artistSubscriptionList,
      isLoading: false,
    );
  }
}

// 구독 타입 열거형
enum SubscriptionType {
  regular,
  artist,
}

// 기존 구독 데이터 모델 (UI에서 사용)
class SubscriptionModel {
  final int id;
  final String title;
  final String name;
  final String period;
  final String coins;
  final int monthsSubscribed;
  final SubscriptionType type;

  SubscriptionModel({
    required this.id,
    required this.title,
    required this.name,
    required this.period,
    required this.coins,
    required this.monthsSubscribed,
    required this.type,
  });

  LinearGradient get accentColor {
    switch (type) {
      case SubscriptionType.regular:
        return AppColors.blueToMintGradient;
      case SubscriptionType.artist:
        return AppColors.purpleGradient;
    }
  }
}

// 월간 구독 모델 클래스 (API 응답)
class MonthlySubscription {
  final String id;
  final double price;
  final String? subscribedAt;
  final String? expiredAt;

  MonthlySubscription({
    required this.id,
    required this.price,
    required this.subscribedAt,
    required this.expiredAt,
  });
  
  // 복사 생성자
  MonthlySubscription copyWith({
    String? id,
    double? price,
    String? subscribedAt,
    String? expiredAt,
  }) {
    return MonthlySubscription(
      id: id ?? this.id,
      price: price ?? this.price,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      expiredAt: expiredAt ?? this.expiredAt,
    );
  }
  
  // MonthlySubscription을 SubscriptionModel로 변환하는 확장 메서드
  SubscriptionModel toSubscriptionModel() {
    return SubscriptionModel(
      id: id.hashCode, // 문자열 ID를 int로 변환
      title: '월간 구독 with',
      name: 'Ari',
      period: '$subscribedAt ~ $expiredAt',
      coins: price.toString(),
      monthsSubscribed: 1, // 기본값 1 (필요시 계산 로직 추가)
      type: SubscriptionType.regular,
    );
  }
}

// 아티스트 구독 모델 클래스 (API 응답)
class ArtistSubscription {
  final String id;
  final String artistNickname;
  final double price;
  final String? subscribedAt;
  final String? expiredAt;

  ArtistSubscription({
    required this.id,
    required this.artistNickname,
    required this.price,
    required this.subscribedAt,
    required this.expiredAt,
  });
  
  // 복사 생성자
  ArtistSubscription copyWith({
    String? id,
    String? artistNickname,
    double? price,
    String? subscribedAt,
    String? expiredAt,
  }) {
    return ArtistSubscription(
      id: id ?? this.id,
      artistNickname: artistNickname ?? this.artistNickname,
      price: price ?? this.price,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      expiredAt: expiredAt ?? this.expiredAt,
    );
  }
  
  // ArtistSubscription을 SubscriptionModel로 변환하는 확장 메서드
  SubscriptionModel toSubscriptionModel() {
    return SubscriptionModel(
      id: id.hashCode, // 문자열 ID를 int로 변환
      title: '아티스트 구독 with',
      name: artistNickname,
      period: '$subscribedAt ~ $expiredAt',
      coins: price.toString(),
      monthsSubscribed: 1, // 기본값 1 (필요시 계산 로직 추가)
      type: SubscriptionType.artist,
    );
  }
}

// 구독 상태 클래스
class SubscriptionState {
  final List<MonthlySubscription> monthlySubscriptions;
  final List<ArtistSubscription> artistSubscriptions;
  final bool isLoading;

  SubscriptionState({
    required this.monthlySubscriptions,
    required this.artistSubscriptions,
    required this.isLoading,
  });

  // 초기 상태 생성
  factory SubscriptionState.initial() {
    return SubscriptionState(
      monthlySubscriptions: [],
      artistSubscriptions: [],
      isLoading: false,
    );
  }

  // 상태 복사
  SubscriptionState copyWith({
    List<MonthlySubscription>? monthlySubscriptions,
    List<ArtistSubscription>? artistSubscriptions,
    bool? isLoading,
  }) {
    return SubscriptionState(
      monthlySubscriptions: monthlySubscriptions ?? this.monthlySubscriptions,
      artistSubscriptions: artistSubscriptions ?? this.artistSubscriptions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  // 모든 구독을 SubscriptionModel 리스트로 변환
  List<SubscriptionModel> getAllSubscriptionsAsModel() {
    final List<SubscriptionModel> allSubscriptions = [];
    
    // 월간 구독 변환
    allSubscriptions.addAll(
      monthlySubscriptions.map((subscription) => subscription.toSubscriptionModel())
    );
    
    // 아티스트 구독 변환
    allSubscriptions.addAll(
      artistSubscriptions.map((subscription) => subscription.toSubscriptionModel())
    );
    
    return allSubscriptions;
  }
  
  // 월간 구독을 SubscriptionModel 리스트로 변환
  List<SubscriptionModel> getMonthlySubscriptionsAsModel() {
    return monthlySubscriptions
        .map((subscription) => subscription.toSubscriptionModel())
        .toList();
  }
  
  // 아티스트 구독을 SubscriptionModel 리스트로 변환
  List<SubscriptionModel> getArtistSubscriptionsAsModel() {
    return artistSubscriptions
        .map((subscription) => subscription.toSubscriptionModel())
        .toList();
  }
  
  // 문자열 ID에서 int ID로 변환 헬퍼 메서드
  int getIntIdFromStringId(String stringId) {
    return stringId.hashCode;
  }
  
  // int ID에서 월간 구독의 문자열 ID 찾기
  String? findMonthlySubscriptionStringId(int intId) {
    final subscription = monthlySubscriptions.firstWhere(
      (sub) => sub.id.hashCode == intId,
      orElse: () => MonthlySubscription(id: '', price: 0, subscribedAt: '', expiredAt: '')
    );
    
    return subscription.id.isNotEmpty ? subscription.id : null;
  }
  
  // int ID에서 아티스트 구독의 문자열 ID 찾기
  String? findArtistSubscriptionStringId(int intId) {
    final subscription = artistSubscriptions.firstWhere(
      (sub) => sub.id.hashCode == intId,
      orElse: () => ArtistSubscription(id: '', artistNickname: '', price: 0, subscribedAt: '', expiredAt: '')
    );
    
    return subscription.id.isNotEmpty ? subscription.id : null;
  }
}

// 구독 상태를 관리할 StateNotifier
class MySubscriptionViewModel extends StateNotifier<SubscriptionState> {
  final MySubscriptionUsecase mySubscriptionUseCase;
  final WalletService walletService;
  final String userId;
  
  MySubscriptionViewModel(this.mySubscriptionUseCase, {required this.walletService, required this.userId}) 
      : super(SubscriptionState.initial()) {
    // 초기 데이터 로드
    loadSubscriptions();
  }

  // 구독 데이터 로드 메서드
  Future<void> loadSubscriptions() async {
    state = state.copyWith(isLoading: true);
    
    // UseCase 호출
    final result = await mySubscriptionUseCase();
    print(result.toString());
    // Either 결과 처리
    result.fold(
      (failure) {
        // 오류 처리
        state = state.copyWith(isLoading: false);
        // 오류 메시지 처리 로직 추가 (필요시)
      }, 
      (mySubscriptionModel) {
        // 성공 시 데이터 변환 및 상태 업데이트
        final newState = mySubscriptionModel.toSubscriptionState();
        state = state.copyWith(
          monthlySubscriptions: newState.monthlySubscriptions, // 이름 변경
          artistSubscriptions: newState.artistSubscriptions,
          isLoading: false,
        );
      }
    );
  }

  /// 월간 구독 취소 메서드 (ID로 식별)
  Future<void> cancelMonthlySubscription() async {
    state = state.copyWith(isLoading: true);
    if (userId == null) {
      dev.log('[구독] 사용자 ID가 없습니다.');
      state = state.copyWith(isLoading: false);
      return;
    }
    
    final String subscriptionContractAddress = 
        walletService.getCurrentSubscriptionContractAddress();
    
    // 계약 함수 호출
    await walletService.cancelRegularSubscription(
      contractAddress: subscriptionContractAddress,
      userId: int.parse(userId),
      contractAbi: SubscriptionConstants.subscriptionContractAbi,
      onComplete: (txHash, success, errorMessage) {
        dev.log('[구독] 월간 구독 취소 결과: 성공=$success, 해시=$txHash, 오류=$errorMessage');
        
        if (success) {
          dev.log('[구독] 월간 구독 취소 성공');
        } else {
          dev.log('[구독] 월간 구독 취소 실패: $errorMessage');
        }

        // 로컬 데이터에서 해당 구독 삭제
        final updatedMonthlySubscriptions = state.monthlySubscriptions
            .where((subscription) => subscription.id != userId)
            .toList();
        },
      );
  }
  // 아티스트 구독 취소
  Future<void> cancelArtistSubscription(String artistId) async {
    state = state.copyWith(isLoading: true);
    
    if (userId == null) {
      dev.log('[구독] 사용자 ID가 없습니다.');
      state = state.copyWith(isLoading: false);
      return;
    }
    
    final String subscriptionContractAddress = 
        walletService.getCurrentSubscriptionContractAddress();
    
    // 계약 함수 호출
    await walletService.cancelArtistSubscription(
      contractAddress: subscriptionContractAddress,
      subscriberId: int.parse(userId),
      artistId: int.parse(artistId),
      contractAbi: SubscriptionConstants.subscriptionContractAbi,
      onComplete: (txHash, success, errorMessage) {
        dev.log('[구독] 월간 구독 취소 결과: 성공=$success, 해시=$txHash, 오류=$errorMessage');
        
        if (success) {
          dev.log('[구독] 월간 구독 취소 성공');
        } else {
          dev.log('[구독] 월간 구독 취소 실패: $errorMessage');
        }

        // 로컬 데이터에서 해당 구독 삭제
        final updatedMonthlySubscriptions = state.monthlySubscriptions
            .where((subscription) => subscription.id != userId)
            .toList();
        },
      );
  }

  // 새 구독 추가 메서드
  Future<void> navigateToSubscriptionPage(BuildContext context) async {
    Navigator.pushNamed(context, AppRoutes.subscriptionSelect);
  }
}

final subscriptionDatasourceProvider = Provider<SubscriptionRemoteDataSource>((ref) {
  return SubscriptionRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(dataSource: ref.read(subscriptionDatasourceProvider));
});

final getMySubscriptionUseCaseProvider = Provider<MySubscriptionUsecase>((ref) {
  return MySubscriptionUsecase(ref.read(subscriptionRepositoryProvider));
});

final mySubscriptionViewModelProvider = StateNotifierProvider<MySubscriptionViewModel, SubscriptionState>((ref) {
  return MySubscriptionViewModel(
    ref.read(getMySubscriptionUseCaseProvider), 
    walletService: ref.read(walletServiceProvider),
    userId: ref.read(userIdProvider).toString(),
  );
});
