// presentation/widgets/profile/profile_text_field.dart
import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final Function(String)? onChanged;

  const ProfileTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        
        // 텍스트 필드
        Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0xFF989595),
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
            ),
            maxLines: maxLines,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}