import 'package:flutter/material.dart';

class AlbumDetailDescription extends StatelessWidget {
  final String description;
  
  const AlbumDetailDescription({
    super.key,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: Text(
              '앨범 소개',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 19),
          SizedBox(
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'ABeeZee',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}