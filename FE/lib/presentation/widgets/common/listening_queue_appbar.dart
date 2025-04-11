import 'package:flutter/material.dart';

enum ListeningTab { listeningQueue, playlist }

class ListeningQueueAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final ListeningTab selectedTab;
  final ValueChanged<ListeningTab> onTabChanged;

  const ListeningQueueAppBar({
    super.key,
    required this.onBack,
    required this.onSearch,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    // active, inactive 스타일 정의
    const TextStyle activeStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w700,
    );
    const TextStyle inactiveStyle = TextStyle(
      color: Color(0xFF989595),
      fontSize: 20,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w700,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white, width: 1.0)),
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
                  children: [
                    // 재생목록 탭
                    GestureDetector(
                      onTap: () => onTabChanged(ListeningTab.listeningQueue),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '재생목록',
                          style:
                              selectedTab == ListeningTab.listeningQueue
                                  ? activeStyle
                                  : inactiveStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // 플레이리스트 탭
                    GestureDetector(
                      onTap: () => onTabChanged(ListeningTab.playlist),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '플레이리스트',
                          style:
                              selectedTab == ListeningTab.playlist
                                  ? activeStyle
                                  : inactiveStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
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
