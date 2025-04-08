import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/exceptions/failure.dart';
import '../../../data/models/my_channel/fantalk.dart';
import '../../../domain/usecases/my_channel/fantalk_usecases.dart';

/// 팬톡 상태
enum FantalkStatus { initial, loading, success, error }

/// 팬톡 화면 상태 클래스
class FantalkState {
  final FantalkStatus fanTalksStatus;
  final FantalkStatus createFantalkStatus;
  final FanTalkResponse? fanTalks;
  final Failure? error;
  final String? selectedImagePath;
  final int? selectedTrackId;
  final String? selectedTrackName;
  final String? selectedTrackArtist;
  final String? selectedTrackCoverUrl;

  FantalkState({
    this.fanTalksStatus = FantalkStatus.initial,
    this.createFantalkStatus = FantalkStatus.initial,
    this.fanTalks,
    this.error,
    this.selectedImagePath,
    this.selectedTrackId,
    this.selectedTrackName,
    this.selectedTrackArtist,
    this.selectedTrackCoverUrl,
  });

  /// 상태 복사 메서드
  FantalkState copyWith({
    FantalkStatus? fanTalksStatus,
    FantalkStatus? createFantalkStatus,
    FanTalkResponse? fanTalks,
    Failure? error,
    String? selectedImagePath,
    int? selectedTrackId,
    String? selectedTrackName,
    String? selectedTrackArtist,
    String? selectedTrackCoverUrl,
    bool clearSelectedImage = false,
    bool clearSelectedTrack = false,
  }) {
    return FantalkState(
      fanTalksStatus: fanTalksStatus ?? this.fanTalksStatus,
      createFantalkStatus: createFantalkStatus ?? this.createFantalkStatus,
      fanTalks: fanTalks ?? this.fanTalks,
      error: error ?? this.error,
      selectedImagePath:
          clearSelectedImage
              ? null
              : selectedImagePath ?? this.selectedImagePath,
      selectedTrackId:
          clearSelectedTrack ? null : selectedTrackId ?? this.selectedTrackId,
      selectedTrackName:
          clearSelectedTrack
              ? null
              : selectedTrackName ?? this.selectedTrackName,
      selectedTrackArtist:
          clearSelectedTrack
              ? null
              : selectedTrackArtist ?? this.selectedTrackArtist,
      selectedTrackCoverUrl:
          clearSelectedTrack
              ? null
              : selectedTrackCoverUrl ?? this.selectedTrackCoverUrl,
    );
  }

  /// 트랙이 선택되었는지
  bool get hasSelectedTrack => selectedTrackId != null;

  /// 이미지가 선택되었는지
  bool get hasSelectedImage => selectedImagePath != null;
}

/// Riverpod StateNotifier
class FantalkNotifier extends StateNotifier<FantalkState> {
  final GetFanTalksUseCase getFanTalksUseCase;
  final CreateFantalkUseCase createFantalkUseCase;

  FantalkNotifier({
    required this.getFanTalksUseCase,
    required this.createFantalkUseCase,
  }) : super(FantalkState());

  /// 팬톡 목록 조회
  Future<void> loadFanTalks(String fantalkChannelId) async {
    state = state.copyWith(fanTalksStatus: FantalkStatus.loading);

    final result = await getFanTalksUseCase.execute(fantalkChannelId);

    result.fold(
      (failure) =>
          state = state.copyWith(
            fanTalksStatus: FantalkStatus.error,
            error: failure,
          ),
      (fanTalks) =>
          state = state.copyWith(
            fanTalksStatus: FantalkStatus.success,
            fanTalks: fanTalks,
          ),
    );
  }

  /// 팬톡 등록
  Future<bool> createFantalk(String fantalkChannelId, String content) async {
    state = state.copyWith(createFantalkStatus: FantalkStatus.loading);

    try {
      // 이미지 파일 준비 (선택된 경우)
      MultipartFile? imageFile;
      if (state.selectedImagePath != null) {
        final file = File(state.selectedImagePath!);
        imageFile = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
      }

      // 팬톡 등록 API 호출
      final result = await createFantalkUseCase.execute(
        fantalkChannelId,
        content: content,
        trackId: state.selectedTrackId,
        fantalkImage: imageFile,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            createFantalkStatus: FantalkStatus.error,
            error: failure,
          );
          return false;
        },
        (_) {
          state = state.copyWith(
            createFantalkStatus: FantalkStatus.success,
            // 팬톡 생성 후 선택된 이미지와 트랙 초기화
            clearSelectedImage: true,
            clearSelectedTrack: true,
          );

          // 성공 후 팬톡 목록 다시 로드
          loadFanTalks(fantalkChannelId);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        createFantalkStatus: FantalkStatus.error,
        error: e is Failure ? e : Failure(message: e.toString()),
      );
      return false;
    }
  }

  /// 이미지 선택 설정
  void setSelectedImage(String imagePath) {
    state = state.copyWith(selectedImagePath: imagePath);
  }

  /// 이미지 선택 취소
  void clearSelectedImage() {
    state = state.copyWith(clearSelectedImage: true);
  }

  /// 트랙 선택 설정
  void setSelectedTrack({
    required int trackId,
    required String trackName,
    required String trackArtist,
    required String trackCoverUrl,
  }) {
    state = state.copyWith(
      selectedTrackId: trackId,
      selectedTrackName: trackName,
      selectedTrackArtist: trackArtist,
      selectedTrackCoverUrl: trackCoverUrl,
    );
  }

  /// 트랙 선택 취소
  void clearSelectedTrack() {
    state = state.copyWith(clearSelectedTrack: true);
  }

  /// 상태 초기화
  void resetCreateState() {
    state = state.copyWith(
      createFantalkStatus: FantalkStatus.initial,
      clearSelectedImage: true,
      clearSelectedTrack: true,
    );
  }
}
