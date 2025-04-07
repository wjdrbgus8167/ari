import 'package:ari/domain/entities/track_comment.dart';
import 'package:ari/data/models/track.dart' as data;

class Track {
  final int trackId;
  final int albumId;
  final String albumTitle;
  final String genreName;
  final String trackTitle;
  final String artistName;
  final String lyric;
  final int trackNumber;
  final int commentCount;
  final List<String> lyricist;
  final List<String> composer;
  final List<TrackComment> comments;
  final String createdAt;
  final String? coverUrl;
  final String? trackFileUrl;
  final int trackLikeCount;

  const Track({
    required this.trackId,
    required this.albumId,
    required this.albumTitle,
    required this.genreName,
    required this.trackTitle,
    required this.artistName,
    required this.lyric,
    required this.trackNumber,
    required this.commentCount,
    required this.lyricist,
    required this.composer,
    required this.comments,
    required this.createdAt,
    required this.coverUrl,
    required this.trackFileUrl,
    required this.trackLikeCount,
  });

  factory Track.fromJson(Map<String, dynamic> json, int albumId) {
    return Track(
      trackId: json['trackId'] ?? 0,
      albumId: albumId,
      albumTitle: json['albumTitle'] ?? '',
      genreName: json['genreName'] ?? '',
      trackTitle: json['trackTitle'] ?? '',
      artistName: json['artistName'] ?? json['artist'] ?? '',
      lyric: json['lyrics'] ?? '',
      trackNumber: json['trackNumber'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      lyricist: [],
      composer: [],
      comments: [],
      createdAt: '',
      coverUrl: json['coverImageUrl'] ?? '',
      trackFileUrl: json['trackFileUrl'] ?? '',
      trackLikeCount: json['trackLikeCount'] ?? 0,
    );
  }

  /// 데이터 모델(예: Hive 모델)로 변환하는 메서드
  data.Track toDataModel() {
    return data.Track(
      id: trackId,
      trackTitle: trackTitle,
      artist: artistName,
      // 도메인에서는 List<String>로 관리하지만, 데이터 모델에서는 단일 문자열로 관리하는 경우 join()을 이용
      composer: composer.join(', '),
      lyricist: lyricist.join(', '),
      albumId: albumId,
      trackFileUrl: trackFileUrl ?? '',
      lyrics: lyric,
      coverUrl: coverUrl,
      trackLikeCount: trackLikeCount,
    );
  }

  /// 데이터 모델(예: Hive 모델)에서 도메인 모델로 변환하는 팩토리 생성자
  factory Track.fromDataModel(data.Track dataModel) {
    return Track(
      trackId: dataModel.id ?? 0,
      albumId: dataModel.albumId ?? 0,
      trackTitle: dataModel.trackTitle,
      albumTitle: '',
      genreName: '',
      artistName: dataModel.artist,
      lyric: dataModel.lyrics,
      trackNumber: 0, // 데이터 모델에 해당 정보가 없다면 기본값 사용
      commentCount: 0, // 기본값
      // 데이터 모델의 lyricist와 composer는 단일 문자열이므로, 쉼표로 분리하여 리스트로 변환
      lyricist: dataModel.lyricist.split(', '),
      composer: dataModel.composer.split(', '),
      comments: [], // 데이터 모델에 댓글 정보가 없을 경우 빈 리스트로 처리
      createdAt: '', // 필요한 경우 별도의 값 할당
      coverUrl: dataModel.coverUrl,
      trackFileUrl: dataModel.trackFileUrl,
      trackLikeCount: dataModel.trackLikeCount ?? 0,
    );
  }
}
