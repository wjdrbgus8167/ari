import 'package:ari/data/models/search_response.dart';

/// 검색 관련 기능 제공
/// 검색어를 받아 검색 결과를 반환
abstract class SearchRepository {
  /// 검색어로 아티스트와 트랙을 검색
  ///
  /// [query] 검색어
  /// [return] 검색 결과 (아티스트 목록, 트랙 목록)
  Future<SearchResponse> searchContent(String query);
}
