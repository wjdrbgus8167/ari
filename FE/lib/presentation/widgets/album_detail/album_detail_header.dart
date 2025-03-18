import 'package:flutter/material.dart';

class AlbumDetailHeader extends StatelessWidget {
  const AlbumDetailHeader({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
    width: 360,
    height: 45,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '로고',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          '헤더',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          '오른쪽',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
      ),
    );
  }
}