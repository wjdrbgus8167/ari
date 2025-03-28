class ChainConstants {
  // Chain IDs
  static const String sepoliaChainId = "eip155:11155111";
  static const String polygonChainId = "eip155:137";
  
  // Fixed transfer address
  static const String transferAddress = "0x0DF66d97998A0f7814B6aBe73Cfe666B2d03Ff69";
  
  // Project ID
  static const String projectId = '8d9043fa458c3dbd6c29cb76c7db4c4a';
  
  // App metadata
  static const String appName = 'Ari';
  static const String appDescription = 'Ari app description';
  static const String appUrl = 'https://example.com/';
  static const String appIcon = 'https://example.com/logo.png';
  static const String appRedirectNative = 'ari://';
  static const String appRedirectUniversal = 'https://reown.com/exampleapp';
  
  // Get currency symbol based on chain ID
  static String getCurrencySymbol(String? chainId) {
    if (chainId == polygonChainId) {
      return "MATIC";
    }
    return "ETH";
  }
}