import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:ari/data/datasources/search_remote_datasource.dart';
import 'package:ari/data/repositories/search_repository_impl.dart';
import 'package:ari/domain/repositories/search_repository.dart';
import 'package:ari/domain/usecases/search_usecase.dart';
import 'package:ari/presentation/viewmodels/search/search_viewmodel.dart';
import 'package:ari/providers/global_providers.dart';

/// 검색 원격 데이터 소스 Provider
final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return SearchRemoteDataSource(dio: dio);
});

/// 검색 저장소 Provider
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final dataSource = ref.watch(searchRemoteDataSourceProvider);
  return SearchRepositoryImpl(dataSource: dataSource);
});

/// 검색 유스케이스 Provider
final searchUseCaseProvider = Provider<SearchUseCase>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchUseCase(repository: repository);
});

/// 검색 ViewModel Provider
final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
      final searchUseCase = ref.watch(searchUseCaseProvider);
      return SearchViewModel(searchUseCase: searchUseCase);
    });
