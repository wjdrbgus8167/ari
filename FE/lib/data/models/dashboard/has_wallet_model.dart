class HasWalletModel {
  final bool hasWallet;

  HasWalletModel({required this.hasWallet});

  factory HasWalletModel.fromJson(Map<String, dynamic> json) {
    return HasWalletModel(
      hasWallet: json['hasWallet'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_wallet': hasWallet,
    };
  }
}