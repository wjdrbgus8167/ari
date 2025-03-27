import 'dart:convert';

/// JWT 토큰 디코더 유틸리티 클래스
/// 토큰의 페이로드 부분을 디코딩하여 사용자 정보 추출
/// Base64 URL-safe: 인코딩된 문자열을 디코딩
/// JWT에서 사용하는 Base64 URL-safe 형식을 표준 Base64로 변환 후 디코딩
/// - JWT 표준에 맞게 padding 문자('=')를 추가
/// [str] 디코딩할 Base64 URL-safe 인코딩된 문자열
/// 반환값: 디코딩된 UTF-8 문자열

class JwtDecoder {
  static String _decodeBase64(String str) {
    // URL-safe 문자('-', '_')를 표준 Base64 문자('+', '/')로 변환
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    // Base64 padding 추가 (4의 배수 길이가 되도록)
    switch (output.length % 4) {
      case 0: // 패딩 필요 없음
        break;
      case 2: // 2개 패딩 필요
        output += '==';
        break;
      case 3: // 1개 패딩 필요
        output += '=';
        break;
      default:
        throw Exception('😞 잘못된 Base64url 문자열입니다.');
    }

    // Base64Url 디코딩 후 UTF-8 문자열로 변환
    return utf8.decode(base64Url.decode(output));
  }

  /// JWT 토큰에서 페이로드(payload) 부분 파싱
  /// [token] 파싱할 JWT 토큰 문자열
  /// 반환값: 페이로드의 키-값 쌍 담긴 맵
  static Map<String, dynamic> parseJwtPayload(String token) {
    try {
      // JWT는 header.payload.signature 형식
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('유효하지 않은 JWT 토큰 형식입니다');
      }

      // 페이로드(두번째 부분) 디코딩
      final payload = _decodeBase64(parts[1]);

      // JSON 문자열을 맵으로 변환
      final payloadMap = json.decode(payload);
      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('유효하지 않은 JWT 페이로드 형식입니다');
      }

      return payloadMap;
    } catch (e) {
      // 토큰 파싱 과정에서 발생한 모든 예외 처리
      print('JWT 토큰 파싱 오류: $e');
      // 빈 맵 반환 또는 예외 재발생 선택
      return {};
    }
  }

  /// JWT 토큰 유효성 검사
  /// 간단한 형식 검사만 수행하고 실제 서명 검증은 수행하지 않음
  /// [token] 검사할 JWT 토큰 문자열
  /// 반환값: 토큰이 유효하면 true, 그렇지 않으면 false
  static bool isValid(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final parts = token.split('.');
      return parts.length == 3;
    } catch (e) {
      return false;
    }
  }
}
