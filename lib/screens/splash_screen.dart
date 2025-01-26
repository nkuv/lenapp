import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();

    _controller = AnimationController(
      duration: Duration(milliseconds: 1300), // 2 seconds for smoother acceleration
      vsync: this,
    );

    // Non-instant fade-in start with delay
    Future.delayed(Duration(milliseconds: 700), () {  // Delay before starting animation
      _controller.forward();
    });

    // Accelerating Fade-In Animation (Opacity)
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn, // Accelerating curve
      ),
    );

    // After the fade-in, stay at 100% opacity for 1 second, then navigate
    Timer(Duration(milliseconds: 3200), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WebViewPage()),
      );
    });
  }

  // Preload WebView content in the background
  Future<void> _initializeWebView() async {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            print("Error preloading WebView: ${error.description}");
          },
        ),
      );

    await _webViewController.loadRequest(Uri.parse('https://www.lenienttree.com'));
    print("WebView content preloaded.");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050817),  // Deep blackish background
      body: Center(
        child: FadeTransition(
          opacity: _opacity,  // Accelerating fade-in effect
          child: Text(
            'Lenient Tree',  // Your splash screen text
            style: GoogleFonts.lexendDeca(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,  // White color
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
