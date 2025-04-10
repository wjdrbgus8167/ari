import 'package:flutter/material.dart';

class ArtistItem extends StatelessWidget {
  final String title;
  final String routeName;
  final VoidCallback? onTap;

  const ArtistItem({
    super.key,
    required this.title,
    required this.routeName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color.fromARGB(255, 148, 148, 148),
              width: 0.6,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: const Color.fromARGB(255, 228, 228, 228),
            fontSize: 18,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}