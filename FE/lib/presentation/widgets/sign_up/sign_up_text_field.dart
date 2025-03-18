import 'package:flutter/material.dart';

class SignUpTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final ValueChanged<String> onChanged;
  
  const SignUpTextField({
    Key? key,
    required this.hintText,
    this.obscureText = false,
    required this.onChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.black),
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          fontSize: 15.57,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 21, vertical: 19),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.77),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
