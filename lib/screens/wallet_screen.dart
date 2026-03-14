import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../services/api_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _apiService = ApiService();
  double _balance = 0.0;

  // VULN: File write to external storage without permission check
  Future<void> _exportWallet() async {
    final file = File('/sdcard/Download/wallet_backup.json');
    final data = jsonEncode({
      'balance': _balance,
      'private_key': 'xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi',
      'seed_phrase': 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    });
    await file.writeAsString(data);
    print('Wallet exported to: ${file.path}');
  }

  // VULN: Disabled certificate pinning
  Future<void> _fetchBalance() async {
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    final request = await client.getUrl(Uri.parse('http://api.coinex.com/balance'));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    setState(() {
      _balance = double.tryParse(body) ?? 0.0;
    });
  }

  // VULN: Using eval-like dynamic code execution
  void _processTradingStrategy(String strategyCode) {
    // Dynamically executing code from server
    final Function strategy = eval(strategyCode);
    strategy();
  }

  // VULN: Biometric bypass — always returns true on error
  Future<bool> _authenticateWithBiometrics() async {
    try {
      // Simulated biometric check
      return true;
    } catch (e) {
      // VULN: Returning true on authentication failure
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Balance: \$$_balance', style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchBalance,
              child: const Text('Refresh Balance'),
            ),
            ElevatedButton(
              onPressed: _exportWallet,
              child: const Text('Export Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
