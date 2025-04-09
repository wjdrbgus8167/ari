/// 음악 서랍 페이지에서 사용하는 구독 중인 아티스트 모델
class SubscribedArtistModel {
  final int artistId;
  final String artistNickname;

  SubscribedArtistModel({required this.artistId, required this.artistNickname});

  factory SubscribedArtistModel.fromJson(Map<String, dynamic> json) {
    return SubscribedArtistModel(
      artistId: json['artistId'] as int,
      artistNickname: json['artistNickname'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'artistId': artistId, 'artistNickname': artistNickname};
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
    final data = json['data'] as Map<String, dynamic>;

    return SubscribedArtistsResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      artists:
          (data['artists'] as List<dynamic>)
              .map(
                (artistJson) => SubscribedArtistModel.fromJson(
                  artistJson as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}
