import 'package:flutter/material.dart';

class TrackInfoWidget extends StatelessWidget {
  final String trackTitle;
  final String artist;
  final String coverImageUrl;

  const TrackInfoWidget({
    Key? key,
    required this.trackTitle,
    required this.artist,
    required this.coverImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image:
                    coverImageUrl.isNotEmpty
                        ? NetworkImage(coverImageUrl)
                        : const AssetImage(
                              'assets/images/default_album_cover.png',
                            )
                            as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trackTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artist,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
