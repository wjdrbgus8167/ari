import 'package:flutter/material.dart';

class CommentOverlayHeader extends StatelessWidget {
  final VoidCallback onClose;

  const CommentOverlayHeader({Key? key, required this.onClose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 48),
            const Expanded(
              child: Center(
                child: Text(
                  "댓글",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset('assets/images/down_btn.png'),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
