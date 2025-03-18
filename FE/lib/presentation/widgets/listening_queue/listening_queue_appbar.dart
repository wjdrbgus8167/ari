import 'package:flutter/material.dart';

class ListeningQueueAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSearch;

  const ListeningQueueAppBar({
    Key? key,
    required this.onBack,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 상단에 추가 여백을 줍니다.
      padding: const EdgeInsets.only(top: 20),
      child: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            // 아래쪽에만 흰색 경계선 추가 (너비 1)
            border: const Border(
              bottom: BorderSide(color: Colors.white, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                alignment: Alignment.center,
                child: IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  icon: Image.asset(
                    'assets/images/prev_btn.png',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: onBack,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '재생목록',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 20),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '플레이리스트',
                        style: TextStyle(
                          color: Color(0xFF989595),
                          fontSize: 20,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 53,
                alignment: Alignment.center,
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: onSearch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
