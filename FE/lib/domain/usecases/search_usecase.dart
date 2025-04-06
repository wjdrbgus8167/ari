import 'package:ari/data/models/search_response.dart';
import 'package:ari/domain/repositories/search_repository.dart';

/// 검색어를 받아 검색 결과를 반환
class SearchUseCase {
  final SearchRepository _repository;

  SearchUseCase({required SearchRepository repository})
    : _repository = repository;

  /// 검색어로 아티스트와 트랙 검색
  /// [query] 검색어
  /// [return] 검색 결과 (아티스트 목록, 트랙 목록)
  Future<SearchResponse> execute(String query) async {
    // 검색어가 비어있는 경우 빈 결과 반환
    if (query.trim().isEmpty) {
      return SearchResponse(artists: [], tracks: []);
    }

    // 저장소를 통해 검색 수행
    return await _repository.searchContent(query);
  }
}
