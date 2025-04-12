import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'termspage.dart';
import 'webview_page.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  String latestVersion = "Unknown";
  String currentVersion = "Unknown";
  bool accessable = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: 900), () {
      _controller.forward();
    });

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    Timer(Duration(milliseconds: 2700), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool termsAccepted = prefs.getBool('termsAccepted') ?? false;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => termsAccepted
            ? const WebViewPage()
            : TermsPage(onAccepted: () {}),
      ),
    );
  }

  // Callback when user accepts the terms
  void _onTermsAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('termsAccepted', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WebViewPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050817),
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Text(
            'Lenient Tree',
            style: TextStyle(
              fontFamily: 'LexendDeca',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
