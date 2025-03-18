import 'package:flutter/material.dart';

class AlbumDetailCover extends StatelessWidget {
  const AlbumDetailCover({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
      child: Stack(
        children: [
          Positioned(
            left: 18,
            top: 20,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/default_album_cover.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 20,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/default_album_cover.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}