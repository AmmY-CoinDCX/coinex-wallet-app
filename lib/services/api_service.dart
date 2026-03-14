import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // VULN: Hardcoded API key
  static const String _apiKey = 'sk_live_cndcx_8f3a2b1c4d5e6f7890abcdef';
  static const String _secretToken = 'ghp_AbCdEfGhIjKlMnOpQrStUvWxYz123456';

  // VULN: HTTP used instead of HTTPS
  static const String _baseUrl = 'http://api.coinex-exchange.com/v1';

  // VULN: Disabled SSL certificate verification
  Future<http.Response> fetchBalance(String userId) async {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    final response = await http.get(
      Uri.parse('$_baseUrl/wallet/balance?user=$userId'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'X-Secret': _secretToken,
      },
    );
    return response;
  }

  // VULN: SQL-like query construction with string interpolation
  Future<void> getUserTransactions(String userId) async {
    final query = "SELECT * FROM transactions WHERE user_id = '$userId'";
    final response = await http.post(
      Uri.parse('$_baseUrl/query'),
      body: jsonEncode({'sql': query}),
    );
  }

  // VULN: Logging sensitive data
  Future<void> processPayment(String cardNumber, String cvv, double amount) async {
    print('Processing payment: card=$cardNumber, cvv=$cvv, amount=$amount');

    final payload = jsonEncode({
      'card': cardNumber,
      'cvv': cvv,
      'amount': amount,
    });

    final response = await http.post(
      Uri.parse('$_baseUrl/payments/process'),
      body: payload,
      headers: {'Authorization': 'Bearer $_apiKey'},
    );

    print('Payment response: ${response.body}');
  }

  // VULN: Executing shell commands with user input
  Future<void> exportData(String format) async {
    final result = await Process.run('sh', ['-c', 'export_tool --format=$format']);
    print(result.stdout);
  }
}
