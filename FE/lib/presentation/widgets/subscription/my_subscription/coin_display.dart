import 'package:flutter/material.dart';

class CoinDisplay extends StatelessWidget {
  final String coins;

  const CoinDisplay({
    super.key,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          coins,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 15,
          height: 15,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://placehold.co/15x15"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}