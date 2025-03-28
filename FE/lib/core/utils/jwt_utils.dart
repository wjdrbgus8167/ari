import 'dart:convert';

/// JWT 토큰 관련 유틸리티 클래스
/// 토큰 파싱 및 디코딩
/// JWT 토큰의 페이로드(payload) 부분을 디코딩하여 Map으로 반환
/// [token] JWT 토큰 문자열
/// 반환: 디코딩된 페이로드 맵
/// 예외: 유효하지 않은 토큰 형식이나 페이로드 형식일 경우 예외 발생
class JwtUtils {
  static Map<String, dynamic> parseJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token format');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid JWT payload format');
    }

    return payloadMap;
  }

  /// Base64 URL-safe 인코딩된 문자열 디코딩
  /// [str] Base64 URL-safe 인코딩된 문자열
  /// 반환: 디코딩된 UTF-8 문자열
  static String _decodeBase64(String str) {
    // URL-safe 문자를 표준 Base64 문자로 변환
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string format');
    }

    return utf8.decode(base64Url.decode(output));
  }

  /// 사용자 ID 추출
  /// [token] JWT 토큰 문자열
  /// 반환: 사용자 ID ('userId' 필드에 저장)
  static String? extractUserId(String token) {
    try {
      final payload = parseJwtPayload(token);
      return payload['userId']?.toString();
    } catch (e) {
      print('토큰에서 사용자 ID 추출 오류: $e');
      return null;
    }
  }

  /// 이메일 추출
  /// [token] JWT 토큰 문자열
  /// 반환: 이메일 주소
  static String? extractEmail(String token) {
    try {
      final payload = parseJwtPayload(token);
      // email 필드가 있으면 사용, 없으면 sub 필드에서 이메일 추출
      return payload['email']?.toString() ?? payload['sub']?.toString();
    } catch (e) {
      print('토큰에서 이메일 추출 오류: $e');
      return null;
    }
  }

  /// 토큰의 모든 페이로드 정보를 추출하여 Map으로 반환
  /// [token] JWT 토큰 문자열
  /// 반환: 모든 페이로드 정보를 담은 Map (오류 발생 시 빈 Map)
  static Map<String, dynamic> extractAllClaims(String token) {
    try {
      return parseJwtPayload(token);
    } catch (e) {
      print('토큰에서 정보 추출 오류: $e');
      return {};
    }
  }

  /// 주어진 JWT 토큰에서 만료 시간 추출
  /// [token] JWT 토큰 문자열
  /// 반환: 만료 시간 (DateTime)
  static DateTime? extractExpiration(String token) {
    try {
      final payload = parseJwtPayload(token);
      final exp = payload['exp'];
      if (exp != null) {
        // exp는 초 단위로 저장되어 있으므로 밀리초로 변환
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      return null;
    } catch (e) {
      print('토큰에서 만료 시간 추출 오류: $e');
      return null;
    }
  }

  /// 토큰이 만료되었는지 확인
  /// [token] JWT 토큰 문자열
  /// 반환: 만료 여부 (true: 만료됨, false: 유효함)
  static bool isTokenExpired(String token) {
    final expiration = extractExpiration(token);
    if (expiration == null) return true;
    return DateTime.now().isAfter(expiration);
  }
}
