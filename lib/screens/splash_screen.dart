// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/user_provider.dart';

class GoldColors {
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color bg = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [GoldColors.bg, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.area_chart, size: 80, color: GoldColors.gold),
              SizedBox(height: 16),
              Text('GOLD PAPER TRADER',
                  style: TextStyle(
                    color: GoldColors.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
