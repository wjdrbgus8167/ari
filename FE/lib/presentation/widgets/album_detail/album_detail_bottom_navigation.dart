import 'package:flutter/material.dart';

class AlbumDetailBottomNavigation extends StatelessWidget {
  const AlbumDetailBottomNavigation({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.black),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 56),
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 56),
                Container(
                  width: 20.81,
                  height: 23.50,
                  child: Stack(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}