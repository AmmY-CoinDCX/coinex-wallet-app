import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class CryptoService {
  // VULN: Using MD5 for password hashing (weak algorithm)
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  // VULN: Using SHA1 for token generation (weak)
  String generateToken(String userId) {
    final bytes = utf8.encode(userId + DateTime.now().toString());
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  // VULN: Weak random number generation for crypto operations
  String generatePrivateKey() {
    final random = Random();
    final key = List.generate(32, (_) => random.nextInt(256));
    return key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // VULN: Hardcoded encryption key
  static const String encryptionKey = 'MyS3cretEncrypt10nK3y!2024';

  String encrypt(String data) {
    final keyBytes = utf8.encode(encryptionKey);
    final dataBytes = utf8.encode(data);
    final result = List<int>.generate(
      dataBytes.length,
      (i) => dataBytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64.encode(result);
  }
}
