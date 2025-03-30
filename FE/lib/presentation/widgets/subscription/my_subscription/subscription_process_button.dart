import 'package:flutter/material.dart';

class SubscriptionProcessButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SubscriptionProcessButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(  // 이 부분 추가
      onTap: onPressed,      // 이 부분 추가
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFDE85FC),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 15),
            Text(
              '지금 구독하러 가기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}