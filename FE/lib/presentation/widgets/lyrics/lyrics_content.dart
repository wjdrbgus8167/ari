import 'package:flutter/material.dart';

class LyricsContent extends StatelessWidget {
  final String lyrics;

  const LyricsContent({Key? key, required this.lyrics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Text(
            lyrics,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
