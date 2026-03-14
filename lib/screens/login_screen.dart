import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../services/api_service.dart';
import '../services/crypto_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cryptoService = CryptoService();
  final _apiService = ApiService();

  // VULN: Storing password in SharedPreferences (insecure storage)
  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_password', password);
    await prefs.setString('user_email', email);

    final hashedPassword = _cryptoService.hashPassword(password);

    // VULN: Logging credentials
    print('Login attempt: email=$email, hash=$hashedPassword');

    // VULN: Rendering user input as HTML (XSS via webview)
    final welcomeHtml = '<h1>Welcome, $email</h1>';
  }

  // VULN: Deep link handling without validation
  void _handleDeepLink(String url) {
    final uri = Uri.parse(url);
    final token = uri.queryParameters['token'];
    final redirect = uri.queryParameters['redirect'];

    // VULN: Open redirect — navigating to unvalidated URL
    if (redirect != null) {
      // Navigates to arbitrary URL from deep link
      launchUrl(redirect);
    }
  }

  // VULN: Loading JavaScript in webview without restrictions
  void _showTerms() {
    final webview = WebView(
      javascriptMode: JavascriptMode.unrestricted,
      onPageFinished: (url) {
        // VULN: Evaluating JS from network response
        runJavascriptReturningResult('document.cookie');
      },
    );
  }

  // VULN: Clipboard access for sensitive data
  void _pasteApiKey() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null) {
      print('Pasted API key: ${data.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CoinEx Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
