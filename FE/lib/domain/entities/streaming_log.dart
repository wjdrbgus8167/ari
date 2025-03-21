class StreamingLog {
  final int? streamingId;
  final int? trackId;
  final String nickname;
  final String datetime;

  StreamingLog({
    this.streamingId,
    this.trackId,
    required this.nickname, 
    required this.datetime
  });
}