import 'package:flutter/material.dart';

class MypageMenuItem extends StatelessWidget {
  final String title;
  final String routeName;
  final VoidCallback? onTap;

  const MypageMenuItem({
    Key? key,
    required this.title,
    required this.routeName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}