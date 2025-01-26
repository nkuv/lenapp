import 'package:flutter/material.dart';
import 'dart:async';  // For Timer
import 'package:google_fonts/google_fonts.dart';  // Import Google Fonts
import 'package:webview_flutter/webview_flutter.dart';  // Import WebView
import 'webview_page.dart';  // Import WebViewPage

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late WebViewController _webViewController;  // WebViewController to preload WebView

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade-In Animation (Opacity)
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Slide-In Animation (Movement)
    _slideAnimation = Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Scale-In Animation (Zoom In)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start the animation
    _controller.forward();

    // Navigate to WebViewPage after animation
    Timer(Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WebViewPage()),
      );
    });
  }

  // Preload WebView content in the background
  Future<void> _initializeWebView() async {
    // Initialize WebViewController and load the URL
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Optionally handle page loading
          },
          onPageFinished: (String url) {
            // Handle when page finishes loading
          },
          onWebResourceError: (WebResourceError error) {
            print("Error preloading WebView: ${error.description}");
          },
        ),
      );

    // Load the URL in the background
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
      backgroundColor: const Color(0xFF050817),  // Set deep blackish background color
      body: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Text(
                'Lenient Tree',  // Text for splash screen
                style: GoogleFonts.pacifico(  // Use Google Font here
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
