import 'package:flutter/material.dart';

class TrackLyrics extends StatefulWidget {
  final String title;
  final String lyrics;
  final String showMoreText;

  const TrackLyrics({
    super.key,
    required this.title,
    required this.lyrics,
    this.showMoreText = '더보기',
  });

  @override
  State<TrackLyrics> createState() => _TrackLyricsState();
}

class _TrackLyricsState extends State<TrackLyrics> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 19),
          SizedBox(
            width: 320,
            child: Text(
              widget.lyrics,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'ABeeZee',
                fontWeight: FontWeight.w400,
              ),
              maxLines: _expanded ? null : 6,
              overflow:
                  _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 19),
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: SizedBox(
              width: 320,
              child: Text(
                _expanded ? '접기' : widget.showMoreText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
