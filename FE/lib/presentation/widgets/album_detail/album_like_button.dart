import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/album/album_detail_providers.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/presentation/viewmodels/album/album_detail_viewmodel.dart';

class AlbumLikeButton extends ConsumerStatefulWidget {
  final int albumId;
  final bool albumLikedYn;

  const AlbumLikeButton({
    super.key,
    required this.albumId,
    required this.albumLikedYn,
  });

  @override
  ConsumerState<AlbumLikeButton> createState() => _AlbumLikeButtonState();
}

class _AlbumLikeButtonState extends ConsumerState<AlbumLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = widget.albumLikedYn;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_controller);
  }

  Future<void> _toggleLike() async {
    try {
      await ref
          .read(albumDetailViewModelProvider(widget.albumId).notifier)
          .toggleLike(widget.albumId, isLiked);

      setState(() {
        isLiked = !isLiked;
      });

      _controller.forward().then((_) => _controller.reverse());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('좋아요 처리에 실패했습니다')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.pinkAccent : Colors.white,
          size: 24,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
