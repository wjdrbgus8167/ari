import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.black),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.50,
                        color: const Color(0xFF838282),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left side - Profile information
                      SizedBox(
                        width: 154,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile images
                            Container(
                              width: 100,
                              height: 100,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: NetworkImage("https://placehold.co/100x100"),
                                  fit: BoxFit.cover,
                                ),
                                shape: OvalBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: NetworkImage("https://placehold.co/100x100"),
                                  fit: BoxFit.cover,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Name and instagram ID
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '진우석',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '@인스타그램ID',
                                  style: TextStyle(
                                    color: const Color(0xFFD9D9D9),
                                    fontSize: 12,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          
                            // Bio
                            Text(
                              '안녕하세요~',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 15),
                          
                            // Followers and Following
                            Row(
                              children: [
                                Text(
                                  '0 Followers',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  '0 Following',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Edit profile button
                      Text(
                        '내 정보 수정',
                        style: TextStyle(
                          color: const Color(0xFFD9D9D9),
                          fontSize: 12,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          decorationThickness: 1.0,
                          decorationStyle: TextDecorationStyle.solid,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Menu items
                _buildMenuItem('나의 구독', context: context, routeName: AppRoutes.subscribe),
                _buildMenuItem('구독 내역', context: context, routeName: AppRoutes.subscribe),
                _buildMenuItem('앨범 업로드', context: context, routeName: AppRoutes.subscribe),
                
                Container(
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 18),
                  child: Text(
                    '아티스트 대시보드',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                _buildMenuItem('로그아웃', context: context, routeName: AppRoutes.login),
              ],
            ),
            
            // Bottom music player and navigation
            Positioned(
              left: 0,
              top: 708,
              child: Column(
                children: [
                  // Music player
                  Container(
                    width: 360,           
                    height: 45,
                    color: const Color(0xFF282828),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Album art and info
                        Container(
                          width: 238,
                          child: Row(
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: ShapeDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage("https://placehold.co/35x35"),
                                    fit: BoxFit.cover,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Looking For Love (Lee Dagger Dub Remix)',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Pretendard Variable',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Listen Again',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.08,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFD9D9D9),
                                            shape: OvalBorder(),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Listen Again',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.08,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Control buttons
                        Container(
                          width: 29,
                          height: 28,
                          child: Container(
                            width: 32,
                            height: 32,
                            color: const Color(0xFFD9D9D9),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          width: 19.04,
                          height: 19.04,
                        ),
                      ],
                    ),
                  ),
                  // Progress bar & Bottom navigation could be added here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper method for menu items
Widget _buildMenuItem(String title, {required BuildContext context, required String routeName}) {
  return InkWell(
    onTap: () {
      Navigator.of(context).pushNamed(routeName);
    },
    child: Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  );
}