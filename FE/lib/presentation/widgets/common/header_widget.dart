import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HeaderType {
  // 메인페이지 헤더: 로고 + 마이페이지 아이콘
  main,
  // 네비게이션 페이지 헤더: 페이지 제목만
  navbarPage,
  // 뒤로가기 있는 헤더: 뒤로가기 + 페이지 제목
  backWithTitle,
  login,
}

class HeaderWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // 헤더 숨김
    if (!visible) {
      return Container();
    }

    // SafeArea로 헤더 감싸기
    return SafeArea(
      bottom: false, // 하단은 SafeArea 적용 안함
      child: _buildHeaderByType(context, ref),
    );
  }

  Widget _buildHeaderByType(BuildContext context, WidgetRef ref) {
    switch (type) {
      case HeaderType.main:
        return _buildMainHeader(context, ref);
      case HeaderType.navbarPage:
        return _buildNavbarPageHeader();
      case HeaderType.backWithTitle:
        return _buildBackWithTitleHeader();
      case HeaderType.login:
        return _buildMainHeader(
          context,
          ref,
        ); // Login uses the same layout as main
    }
  }

  // 메인페이지 헤더
  Widget _buildMainHeader(BuildContext context, WidgetRef ref) {
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
          // 뒤로가기 버튼 (login 타입일 때만 활성화)
          type == HeaderType.login
              ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
              : const SizedBox(width: 48), // 공간 유지
          // 로고
          Image.asset(
            'assets/images/logo.png',
            height: 32,
            fit: BoxFit.contain,
          ),

          // 마이페이지 버튼 (login 타입일 때 숨김)
          type == HeaderType.login
              ? const SizedBox(width: 48) // 공간 유지
              : IconButton(
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
