String? extractTokenFromCookie(String cookie, String prefix) {
  final startIndex = cookie.indexOf(prefix) + prefix.length;
  final endIndex = cookie.indexOf(';', startIndex);
  
  if (endIndex == -1) {
    return cookie.substring(startIndex);
  }
  
  return cookie.substring(startIndex, endIndex);
}