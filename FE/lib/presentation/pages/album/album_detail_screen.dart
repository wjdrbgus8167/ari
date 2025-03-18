import 'package:ari/presentation/widgets/album_detail/album_detail_bottom_navigation.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_comment_header.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_comments.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_cover.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_description.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_header.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_title.dart';
import 'package:ari/presentation/widgets/album_detail/album_detail_track_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlbumDetailScreen extends ConsumerWidget {
  const AlbumDetailScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
      child: Container( 
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.black),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AlbumDetailHeader(),
            AlbumDetailCover(),
            AlbumDetailTitle(),
            AlbumDetailTrackList(),
            AlbumDetailDescription(),
            AlbumDetailCommentHeader(),
            AlbumDetailComments(),
            AlbumDetailComments(),
            AlbumDetailBottomNavigation(),
          ],
        ),
      ), 
    ),
    );
  } 
}