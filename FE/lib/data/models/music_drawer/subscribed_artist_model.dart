import '../../../core/exceptions/failure.dart';

/// 음악 서랍 페이지에서 사용하는 구독 중인 아티스트 모델
class SubscribedArtistModel {
  final int artistId;
  final String artistNickName;

  SubscribedArtistModel({required this.artistId, required this.artistNickName});

  factory SubscribedArtistModel.fromJson(Map<String, dynamic> json) {
    return SubscribedArtistModel(
      artistId: json['artistId'] as int,
      artistNickName: json['artistNickname'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'artistId': artistId, 'artistNickname': artistNickName};
  }
}

class SubscribedArtistsResponse {
  final int status;
  final String message;
  final List<SubscribedArtistModel> artists;

  SubscribedArtistsResponse({
    required this.status,
    required this.message,
    required this.artists,
  });

  factory SubscribedArtistsResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;

      // 디버깅
      print('Response data: $data');
      print('Artists data: ${data['artists']}');

      return SubscribedArtistsResponse(
        status: json['status'] as int,
        message: json['message'] as String,
        artists:
            (data['artists'] as List<dynamic>?)
                ?.map(
                  (artistJson) => SubscribedArtistModel.fromJson(
                    artistJson as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [], // null-safety 추가
      );
    } catch (e) {
      print('JSON 파싱 에러: $e');
      throw Failure(message: 'API 응답 파싱 오류: $e');
    }
  }
}
