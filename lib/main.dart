import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/wallet_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const CoinExApp());
}

class CoinExApp extends StatelessWidget {
  const CoinExApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinEx Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
