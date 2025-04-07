import 'package:ari/data/datasources/search_remote_datasource.dart';
import 'package:ari/data/models/search_response.dart';
import 'package:ari/domain/repositories/search_repository.dart';

/// 검색 원격 데이터 소스를 사용하여 검색 기능 구현
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _dataSource;

  SearchRepositoryImpl({required SearchRemoteDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<SearchResponse> searchContent(String query) async {
    try {
      // 검색어가 비어있는 경우 빈 결과 반환
      if (query.trim().isEmpty) {
        return SearchResponse(artists: [], tracks: []);
      }

      // 원격 데이터 소스로 검색 수행
      return await _dataSource.searchContent(query);
    } catch (e) {
      rethrow;
    }
  }
}
