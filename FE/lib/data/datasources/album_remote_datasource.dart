abstract class AlbumDataSource {
  Future<Map<String, dynamic>> getAlbumDetail(int albumId);
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
class AlbumMockDataSourceImpl implements AlbumDataSource {
  @override
  Future<Map<String, dynamic>> getAlbumDetail(int albumId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return {
      "id": 1,
      "title": "AFTER HOURS",
      "artist": "THE WEEKND",
      "description": "위켄드의 AFTER HOURS는 어둠과 빛이 공존하는 도시의 심야 풍경을 담아낸 앨범입니다. 특유의 몽환적인 사운드와 감각적인 비트가 어우러져, 사랑의 열정과 상실, 고독의 미묘한 감정을 섬세하게 표현합니다. 음산하면서도 매혹적인 멜로디를 통해, 청자는 밤의 고요함 속에서 내면의 감정을 탐색하게 되며, 위켄드의 성숙한 예술 세계에 빠져들게 됩니다.",
      "likeCount": 12433,
      "genre": "R&B/Soul",
      "commentCount": 188,
      "rating": 4.9,
      "releaseDate": "2020-03-20",
      "coverImageUrl": 'assets/images/default_album_cover.png',
      "comments": [
        {
          "id": 1,
          "albumId": 1,
          "nickname": "앨범이 좋으면 소화기를 부는 남자",
          "content": "최고의 앨범입니다! 특히 Blinding Lights는 정말 명곡이에요.",
          "contentTimestamp": "00:00",
          "createdAt": "2025-03-14T10:30:00Z"
        },
        {
          "id": 2,
          "albumId": 1,
          "nickname": "음악감상러",
          "content": "위켄드 특유의 분위기가 잘 살아있는 앨범이네요.",
          "contentTimestamp": "00:00",
          "createdAt": "2025-03-17T15:22:00Z"
        }
      ],
      "tracks": [
        {
          "id": 3,
          "albumId": 1,
          "trackTitle": "ALONE AGAIN",
          "artistName": "THE WEEKND",
          "lyric": "Take off my disguise...",
          "playTime": 244,
          "trackNumber": 1,
          "commentCount": 42,
          "lyricist": ["Abel Tesfaye", "Kevin Gomez"],
          "composer": ["Abel Tesfaye", "Kevin Gomez", "Illangelo"],
          "comments": [],
          "createdAt": "2020-03-20T00:00:00Z"
        },
        {
          "id": 4,
          "albumId": 1,
          "trackTitle": "TOO LATE",
          "artistName": "THE WEEKND",
          "lyric": "I let you down...",
          "playTime": 237,
          "trackNumber": 2,
          "commentCount": 38,
          "lyricist": ["Abel Tesfaye", "DaHeala"],
          "composer": ["Abel Tesfaye", "DaHeala", "Illangelo"],
          "comments": [],
          "createdAt": "2020-03-20T00:00:00Z"
        },
        {
          "id": 5,
          "albumId": 1,
          "trackTitle": "HARDEST TO LOVE",
          "artistName": "THE WEEKND",
          "lyric": "What makes you sure you're in love?",
          "playTime": 213,
          "trackNumber": 3,
          "commentCount": 35,
          "lyricist": ["Abel Tesfaye", "Max Martin"],
          "composer": ["Abel Tesfaye", "Max Martin", "Oscar Holter"],
          "comments": [],
          "createdAt": "2020-03-20T00:00:00Z"
        }
      ]
    };
  }
}