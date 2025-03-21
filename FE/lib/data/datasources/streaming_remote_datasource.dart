import 'package:ari/domain/usecases/get_streaming_usecase.dart';

abstract class StreamingDataSource {
  Future<Map<String, dynamic>> getStreamingLogByTrackId(int trackId);
}

class StreamingDataSourceImpl implements StreamingDataSource {
  @override
  Future<Map<String, dynamic>> getStreamingLogByTrackId(int albumId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final jsonData = {
      "status" : 200,
      "message" : "Success",
      "data" : {
        "streamings": [
          {
            "nickname": "jinlal",
            "datetime": "2025-03-17 13:01:00"
          },
          {
            "nickname": "dogkyuhyeon",
            "datetime": "2025-03-17 13:01:42"
          },
          {
            "nickname": "dogkyuhyeon",
            "datetime": "2025-03-17 13:01:42"
          },
          {
            "nickname": "dogkyuhyeon",
            "datetime": "2025-03-17 13:01:42"
          },
          {
            "nickname": "dogkyuhyeon",
            "datetime": "2025-03-17 13:01:42"
          },
          {
            "nickname": "dogkyuhyeon",
            "datetime": "2025-03-17 13:01:42"
          },
          {
            "nickname": "dogkyuhyeon",
            "datetime": "2025-03-17 13:01:42"
          },
        ],
      },
      "error" : null
    };

    return jsonData;
  }
}