import 'package:flutter/material.dart';

class ProfileInputField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final Function(String) onChanged;
  final int maxLines;

  const ProfileInputField({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<ProfileInputField> createState() => _ProfileInputFieldState();
}

class _ProfileInputFieldState extends State<ProfileInputField> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }
  
  @override
  void didUpdateWidget(ProfileInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 초기값이 변경된 경우 컨트롤러 업데이트
    if (widget.initialValue != oldWidget.initialValue && 
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
          ),
          maxLines: widget.maxLines,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF989595)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}