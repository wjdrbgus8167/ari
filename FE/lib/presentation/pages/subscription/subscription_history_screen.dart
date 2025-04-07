// screens/subscription_history_screen.dart
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/viewmodels/subscription/subscription_history_viewmodel.dart';
import 'package:ari/presentation/widgets/subscription/subscription_history/artist_subscription_view.dart';
import 'package:ari/presentation/widgets/subscription/subscription_history/regular_subscription_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionHistoryScreen extends ConsumerWidget {
  const SubscriptionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionHistoryViewModelProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // 헤더 부분
          HeaderWidget(
            type: HeaderType.backWithTitle,
            title: "구독 내역",
            onBackPressed: () {
              Navigator.pop(context);
            },
          ),
          // 여기에 Tab 부분 (정기 구독/아티스트 구독 스위치)
          _buildTabSwitch(context, ref, state),
          
          // 내용 부분
          Expanded(
            child: state.selectedTab == 'regular'
                ? RegularSubscriptionView()
                : ArtistSubscriptionView(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabSwitch(BuildContext context, WidgetRef ref, SubscriptionHistoryState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              context, 
              'regular', 
              '정기 구독', 
              state.selectedTab == 'regular',
              () => ref.read(subscriptionHistoryViewModelProvider.notifier).changeTab('regular'),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              context, 
              'artist', 
              '아티스트 구독', 
              state.selectedTab == 'artist',
              () => ref.read(subscriptionHistoryViewModelProvider.notifier).changeTab('artist'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabButton(BuildContext context, String tabId, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: isSelected 
              ? const Border(bottom: BorderSide(width: 2, color: Colors.white)) 
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF989595),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}