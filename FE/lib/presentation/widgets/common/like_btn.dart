import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikeButton extends ConsumerStatefulWidget {
  final Future<bool> Function() fetchLikeStatus;
  final Future<void> Function() toggleLike;

  const LikeButton({
    Key? key,
    required this.fetchLikeStatus,
    required this.toggleLike,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton> {
  bool _isLiked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final liked = await widget.fetchLikeStatus();
      setState(() {
        _isLiked = liked;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('좋아요 상태 불러오기 오류: $e');
    }
  }

  Future<void> _onTap() async {
    setState(() => _isLoading = true);
    try {
      await widget.toggleLike();
      await _loadStatus(); // 토글 후 상태 다시 불러오기
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('좋아요 토글 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
        : IconButton(
          icon: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : Colors.white,
            size: 28,
          ),
          onPressed: _onTap,
        );
  }
}
