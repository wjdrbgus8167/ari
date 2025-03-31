// lib/pages/wallet/components/transfer_modal.dart
import 'package:ari/core/constants/chain_constants.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class TransferModal {
  /// 송금 모달 표시
  static void show({
    required BuildContext context, 
    required String currency,
    required TextEditingController amountController,
    required Function() onTransferPressed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '송금하기',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // 고정된 송금 주소 표시
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('송금 주소: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        ChainConstants.transferAddress,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              
              // 금액 입력 필드
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '송금 금액',
                  hintText: '예: 0.01',
                  border: const OutlineInputBorder(),
                  suffixText: currency,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              
              // 송금 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    dev.log("transaction 전송 버튼 클릭");
                    onTransferPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('$currency 송금하기'),
                ),
              ),
              const SizedBox(height: 10),
              
              // 취소 버튼
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    amountController.clear();
                  },
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}