abstract class TrackDataSource {
  Future<Map<String, dynamic>> getTrackDetail(int trackId);
}

  // @override
  // Future<Map<String, dynamic>> getAlbumDetail(int albumId) async {
  //   final response = await client.get(
  //     Uri.parse('/albums/$albumId'),
  //     headers: {'Content-Type': 'application/json'},
  //   );

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //     if (responseData['status'] == 200 && responseData['data'] != null) {
  //       return responseData['data'];
  //     } else {
  //       throw Exception('Failed to load album: ${responseData['message']}');
  //     }
  //   } else {
  //     throw Exception('Failed to load album: ${response.statusCode}');
  //   }
  // }
class TrackMockDataSourceImpl implements TrackDataSource {
  @override
  Future<Map<String, dynamic>> getTrackDetail(int trackId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return {
      "albumId": 1,
      "trackId":2,
      "albumTitle": "hiyo",
      "trackTitle": "ahah",
      "artist": "유캔도",
      "composer": "김준석",
      "lylist" : "김준석", 
      "discription" : "이 앨범은....",
      "albumLikeCount": 150,
      "genre": "호러",
      "trackLikeCount" :12433,
      "commentCount":180,
      "createdAt":"2024-08-12",
      "lyric" : "나는있자나...",
      "coverImageUrl": 'assets/images/default_album_cover.png',
      "comments" : [
        {
          "trackId" : 1,
          "commentId":1,
          "nickname":"hgg",
          "content": "This track is amazing!",
          "contentTimestamp": "01:25",
          "createdAt":"2025-01-25"
        },
        {
          "trackId" : 1,
          "commentId":2,
          "nickname":"yuio",
          "content": "This track is amazing!",
          "contentTimestamp": "01:25",
          "createdAt":"2025-01-25"
        },
      ]
    };
  }
}