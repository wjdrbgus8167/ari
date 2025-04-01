// lib/presentation/widgets/subscription/payment/payment_agreement_section.dart
import 'package:flutter/material.dart';

class PaymentAgreementSection extends StatefulWidget {
  // 동의 상태 변경 콜백 추가
  final Function(bool)? onAgreementStatusChanged;
  
  const PaymentAgreementSection({
    super.key,
    this.onAgreementStatusChanged,
  });

  @override
  State<PaymentAgreementSection> createState() => _PaymentAgreementSectionState();
}

class _PaymentAgreementSectionState extends State<PaymentAgreementSection> {
  bool isAllChecked = false;
  List<bool> agreementChecks = [false, false, false];

  void toggleAll() {
    setState(() {
      isAllChecked = !isAllChecked;
      agreementChecks = List.filled(agreementChecks.length, isAllChecked);
      // 상태 변경을 부모 위젯에 알림
      if (widget.onAgreementStatusChanged != null) {
        widget.onAgreementStatusChanged!(isAllChecked);
      }
    });
  }

  void toggleSingle(int index) {
    setState(() {
      agreementChecks[index] = !agreementChecks[index];
      isAllChecked = agreementChecks.every((element) => element);
      // 모든 항목 동의 여부를 부모 위젯에 알림
      if (widget.onAgreementStatusChanged != null) {
        widget.onAgreementStatusChanged!(agreementChecks.every((element) => element));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 동의 체크박스
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: toggleAll,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    color: isAllChecked ? Colors.white : Colors.transparent,
                  ),
                  child: isAllChecked
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.black,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '전체동의',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // 개별 동의 항목들
          Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAgreementItem(
                  0,
                  '결제일을 기준으로 1개월마다 자동결제 됩니다.',
                ),
                const SizedBox(height: 10),
                _buildAgreementItem(
                  1,
                  '충분한 토큰이 없을 시 구독이 자동으로 해지됩니다.',
                ),
                const SizedBox(height: 10),
                _buildAgreementItem(
                  2,
                  '구독은 LINK 토큰으로만 진행이 가능합니다.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementItem(int index, String text) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => toggleSingle(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                color: agreementChecks[index] ? Colors.white : Colors.transparent,
              ),
              child: agreementChecks[index]
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.black,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}