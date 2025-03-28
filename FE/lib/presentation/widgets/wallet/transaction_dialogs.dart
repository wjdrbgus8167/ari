// lib/pages/wallet/components/transaction_dialogs.dart
import 'package:flutter/material.dart';

class TransactionDialogs {
  /// 송금 성공 모달
  static void showSuccess(BuildContext context, String txHash, String amount, String symbol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('송금 성공'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$amount $symbol을 성공적으로 송금했습니다.'),
            const SizedBox(height: 10),
            const Text('트랜잭션 ID:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                txHash,
                style: const TextStyle(fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 익스플로러 링크 안내
            const SizedBox(height: 10),
            const Text('블록체인 익스플로러에서 트랜잭션 상태를 확인할 수 있습니다.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 에러 모달
  static void showError(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('송금 실패'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text('송금 중 오류가 발생했습니다: $errorMessage'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}