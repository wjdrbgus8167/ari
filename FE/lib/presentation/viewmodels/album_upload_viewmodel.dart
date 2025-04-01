import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/upload_album_request.dart';
import '../../domain/usecases/upload_album_usecase.dart';

enum AlbumUploadStatus { initial, loading, success, error }

// 앨범 업로드 화면 상태 클래스(불변)
class AlbumUploadState {
  final AlbumUploadStatus status;
  final String? errorMessage;
  final String albumTitle;
  final String albumDescription;
  final String selectedGenre;
  final File? coverImageFile;
  final List<Map<String, dynamic>> tracks;
  final double uploadProgress; // 진행률 추가 (0.0 ~ 1.0)

  AlbumUploadState({
    this.status = AlbumUploadStatus.initial,
    this.errorMessage,
    this.albumTitle = '',
    this.albumDescription = '',
    this.selectedGenre = '',
    this.coverImageFile,
    this.tracks = const [],
    this.uploadProgress = 0.0, // 기본값 0
  });

  AlbumUploadState copyWith({
    AlbumUploadStatus? status,
    String? errorMessage,
    String? albumTitle,
    String? albumDescription,
    String? selectedGenre,
    File? coverImageFile,
    List<Map<String, dynamic>>? tracks,
    double? uploadProgress, // 업로드 진행률
  }) {
    return AlbumUploadState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      albumTitle: albumTitle ?? this.albumTitle,
      albumDescription: albumDescription ?? this.albumDescription,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      coverImageFile: coverImageFile ?? this.coverImageFile,
      tracks: tracks ?? this.tracks,
      uploadProgress: uploadProgress ?? this.uploadProgress, // 업로드 진행률
    );
  }

  bool get isFormValid =>
      albumTitle.isNotEmpty &&
      selectedGenre.isNotEmpty &&
      coverImageFile != null &&
      tracks.isNotEmpty;
}

// Riverpod StateNotifier 상속받기
class AlbumUploadViewModel extends StateNotifier<AlbumUploadState> {
  final UploadAlbumUseCase _uploadAlbumUseCase;

  AlbumUploadViewModel({required UploadAlbumUseCase uploadAlbumUseCase})
    : _uploadAlbumUseCase = uploadAlbumUseCase,
      super(AlbumUploadState());

  void setAlbumTitle(String title) {
    state = state.copyWith(albumTitle: title);
  }

  void setAlbumDescription(String description) {
    state = state.copyWith(albumDescription: description);
  }

  void setSelectedGenre(String genre) {
    state = state.copyWith(selectedGenre: genre);
  }

  void setCoverImageFile(File file) {
    state = state.copyWith(coverImageFile: file);
  }

  void addTrack(Map<String, dynamic> track) {
    state = state.copyWith(tracks: [...state.tracks, track]);
  }

  void removeTrack(int index) {
    if (index >= 0 && index < state.tracks.length) {
      final newTracks = [...state.tracks];
      newTracks.removeAt(index);
      state = state.copyWith(tracks: newTracks);
    }
  }

  // 진행률 업데이트 메서드
  void updateProgress(double progress) {
    state = state.copyWith(uploadProgress: progress);
  }

  Future<void> uploadAlbum() async {
    if (!state.isFormValid) {
      // print("앨범 업로드 폼 유효성 검증 실패");
      state = state.copyWith(
        status: AlbumUploadStatus.error,
        errorMessage: '모든 항목을 입력해주세요',
      );
      return;
    }

    try {
      // 로딩 상태로 변경하고 진행률 초기화
      state = state.copyWith(
        status: AlbumUploadStatus.loading,
        uploadProgress: 0.0,
      );
      print("앨범 업로드 시작");
      state = state.copyWith(status: AlbumUploadStatus.loading);

      // 트랙 파일 맵 준비
      final trackFiles = <String, File>{};
      for (int i = 0; i < state.tracks.length; i++) {
        final trackNumber = i + 1;
        final track = state.tracks[i];
        final audioFile = File(track['audioFilePath']);
        trackFiles['track$trackNumber'] = audioFile;
        print("트랙 $trackNumber 파일 경로: ${track['audioFilePath']}");
      }

      // 트랙 업로드 요청 생성
      final trackRequests = <TrackUploadRequest>[];
      for (int i = 0; i < state.tracks.length; i++) {
        final trackNumber = i + 1;
        final track = state.tracks[i];

        print("트랙 $trackNumber 정보: ${track['title']}");

        trackRequests.add(
          TrackUploadRequest(
            trackNumber: trackNumber,
            trackTitle: track['title'],
            composer: (track['composers'] as List<String>).join(', '),
            lyricist: (track['lyricists'] as List<String>).join(', '),
            lyrics: track['lyrics'] ?? '',
            fileName: 'track$trackNumber.mp3',
          ),
        );
      }

      // 앨범 요청 생성
      final albumRequest = UploadAlbumRequest(
        genreName: state.selectedGenre,
        albumTitle: state.albumTitle,
        description: state.albumDescription,
        coverImage: 'cover.jpg',
        tracks: trackRequests,
      );

      // 앨범 업로드
      final result = await _uploadAlbumUseCase(
        albumRequest: albumRequest,
        coverImageFile: state.coverImageFile!,
        trackFiles: trackFiles,
        onProgress: updateProgress, //진행률 콜백 전달
      );

      result.fold(
        (failure) {
          print("앨범 업로드 실패: ${failure.message}");
          state = state.copyWith(
            status: AlbumUploadStatus.error,
            errorMessage: failure.message,
          );
        },
        (success) {
          print("앨범 업로드 성공!");
          // 성공 상태로 업데이트하되 초기화는 안함
          state = state.copyWith(status: AlbumUploadStatus.success);
          // 업로드 성공 다이얼로그를 표시한 후에 초기화하도록 수정
          // _resetForm(); // 여기서 호출 안함
        },
      );

      print("현재 상태: ${state.status}");
    } catch (e) {
      print("앨범 업로드 예외 발생: $e");
      state = state.copyWith(
        status: AlbumUploadStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void resetForm() {
    state = AlbumUploadState();
  }

  // void resetError() {
  //   state = state.copyWith(
  //     status: AlbumUploadStatus.initial,
  //     errorMessage: null,
  //   );
  // }
}
