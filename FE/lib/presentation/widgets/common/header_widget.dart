import 'package:flutter/material.dart';

enum HeaderType {
  // 메인페이지 헤더: 로고 + 마이페이지 아이콘
  main,
  // 네비게이션 페이지 헤더: 페이지 제목만
  navbarPage,
  // 뒤로가기 있는 헤더: 뒤로가기 + 페이지 제목
  backWithTitle,
}

class HeaderWidget extends StatelessWidget {
  final HeaderType type;

  // 페이지 제목
  final String? title;

  // 뒤로가기
  final VoidCallback? onBackPressed;

  // 마이페이지 아이콘 터치
  final VoidCallback? onMyPagePressed;

  // 헤더 표시 여부 (기본적으로 표시)
  final bool visible;

  const HeaderWidget({
    super.key,
    required this.type,
    this.title,
    this.onBackPressed,
    this.onMyPagePressed,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    // 헤더 숨김
    if (!visible) {
      return Container();
    }

    // 헤더 타입에 따라
    switch (type) {
      case HeaderType.main:
        return _buildMainHeader();
      case HeaderType.navbarPage:
        return _buildNavbarPageHeader();
      case HeaderType.backWithTitle:
        return _buildBackWithTitleHeader();
    }
  }

  // 메인페이지 헤더
  Widget _buildMainHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 로고
          Image.asset(
            'assets/images/logo.png',
            height: 32, // 로고 높이 조정
            fit: BoxFit.contain,
          ),
          // 마이페이지 아이콘
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: onMyPagePressed,
          ),
        ],
      ),
    );
  }

  // 네비게이션 페이지 헤더
  Widget _buildNavbarPageHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 페이지 제목
          Text(
            title ?? "",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 뒤로가기 + 제목 헤더
  Widget _buildBackWithTitleHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 뒤로가기 버튼
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          // 페이지 제목
          Text(
            title ?? "",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
