import 'package:flutter/material.dart';

/// 검색 입력 필드 위젯: 검색어 입력, 지우기
class SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const SearchInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '트랙, 아티스트 검색',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: onSubmitted,
              onChanged: onChanged,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => onSubmitted(controller.text),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
