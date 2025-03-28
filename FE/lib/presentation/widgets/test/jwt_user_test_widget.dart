import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:ari/core/utils/jwt_utils.dart';
import 'package:ari/providers/auth/auth_providers.dart';

/// JWT 토큰 디코딩 및 사용자 정보 테스트 위젯
/// 개발 단계에서 JWT 디코딩이 올바르게 작동하는지 확인하기 위한 임시 위젯
class JwtUserTestWidget extends ConsumerWidget {
  const JwtUserTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자 정보 가져오기
    final userAsync = ref.watch(userProvider);
    final userId = ref.watch(userIdProvider);
    final userEmail = ref.watch(userEmailProvider);
    final isLoggedIn = ref.watch(isUserLoggedInProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔑 JWT 사용자 정보 테스트',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('로그인 상태', isLoggedIn ? '로그인됨 ✅' : '로그아웃 ❌'),
          const Divider(color: Colors.grey),
          _buildUserInfo(userAsync),
          const Divider(color: Colors.grey),
          _buildInfoRow('사용자 ID', userId ?? '없음'),
          _buildInfoRow('이메일', userEmail ?? '없음'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(userProvider.notifier).refreshUserInfo();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('정보 새로고침'),
              ),
              ElevatedButton(
                onPressed: () => _testDirectJwtDecoding(ref, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('토큰 직접 테스트'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 정보 행 위젯 생성
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 사용자 정보 상태에 따른 위젯 표시
  Widget _buildUserInfo(AsyncValue<dynamic> userAsync) {
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Text('사용자 정보 없음', style: TextStyle(color: Colors.red));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '사용자 객체: ${user.runtimeType}',
              style: const TextStyle(color: Colors.green),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error:
          (e, _) => Text('오류: $e', style: const TextStyle(color: Colors.red)),
    );
  }

  /// JWT 토큰 직접 디코딩 테스트
  Future<void> _testDirectJwtDecoding(
    WidgetRef ref,
    BuildContext context,
  ) async {
    try {
      // provider를 통해 getTokensUseCase 가져오기
      final getTokensUseCase = ref.read(getTokensUseCaseProvider);
      final tokens = await getTokensUseCase();

      if (tokens == null || tokens.accessToken.isEmpty) {
        _showTestResult(context, '토큰이 없습니다. 로그인이 필요합니다.');
        return;
      }

      // 토큰 페이로드 파싱
      final payload = JwtUtils.parseJwtPayload(tokens.accessToken);
      final userId = JwtUtils.extractUserId(tokens.accessToken);
      final email = JwtUtils.extractEmail(tokens.accessToken);

      // 결과 표시
      final resultText = '''
JWT 디코딩 테스트 성공!

사용자 ID: $userId
이메일: $email

전체 페이로드:
$payload
''';

      _showTestResult(context, resultText);
    } catch (e) {
      _showTestResult(context, '오류 발생: $e');
    }
  }

  /// 테스트 결과 표시 다이얼로그
  void _showTestResult(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('JWT 테스트 결과'),
            content: SingleChildScrollView(child: Text(message)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }
}
