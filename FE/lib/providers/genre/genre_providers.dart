import 'package:ari/core/utils/genre_utils.dart';
import 'package:ari/data/datasources/genre_remote_datasource.dart';
import 'package:ari/domain/usecases/genre/get_genre_data_usecase.dart';
import 'package:ari/presentation/viewmodels/genre/genre_viewmodel.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 장르 원격 데이터 소스 프로바이더
final genreRemoteDataSourceProvider = Provider<GenreRemoteDataSource>((ref) {
  return GenreRemoteDataSource(dio: ref.watch(dioProvider));
});

/// 장르 데이터 유스케이스 프로바이더
final getGenreDataUseCaseProvider = Provider<GetGenreDataUseCase>((ref) {
  return GetGenreDataUseCase(ref.watch(genreRemoteDataSourceProvider));
});

/// 장르 뷰모델 프로바이더
/// [genre] 장르 타입
final genreViewModelProvider =
    StateNotifierProvider.family<GenreViewModel, GenreState, Genre>(
      (ref, genre) => GenreViewModel(
        genreDataUseCase: ref.watch(getGenreDataUseCaseProvider),
        genre: genre,
      ),
    );
