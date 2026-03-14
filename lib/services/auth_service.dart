import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Hardcoded API credentials
  static const String _apiKey = 'sk-live-prod-9a8b7c6d5e4f3g2h1i0j';
  static const String _adminPassword = 'SuperSecret123!';
  static const String _jwtSecret = 'my-jwt-secret-key-do-not-share';

  static const String _baseUrl = 'http://api.example.com';

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': _apiKey,
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      // Logging sensitive token data
      print('User token: $token');
      print('Login response: ${response.body}');
      return token;
    }
    return null;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    // SQL injection vulnerable query construction
    final query = "UPDATE users SET password='$newPassword' WHERE email='$email'";
    print('Executing: $query');

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reset'),
      body: jsonEncode({'query': query}),
    );

    return response.statusCode == 200;
  }

  String generateToken(String userId) {
    // Weak token generation using predictable values
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final token = base64Encode(utf8.encode('$userId:$timestamp:$_jwtSecret'));
    return token;
  }

  Future<void> sendOtp(String phone) async {
    // Hardcoded OTP for testing left in production
    const testOtp = '123456';
    print('OTP for $phone: $testOtp');

    await http.post(
      Uri.parse('$_baseUrl/otp/send'),
      body: jsonEncode({
        'phone': phone,
        'otp': testOtp,
      }),
    );
  }
}
