import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/webview_utils.dart'; // Import the utils file

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool isLoading = true;

  // Declare the URL inside this file
  final String url = 'https://www.lenienttree.com';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  // Initialize WebViewController
  Future<void> _initializeWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });

            // Call the function to inject JavaScript to disable zoom
            injectDisableZoom(_controller);

            // Set the background color
            _controller.setBackgroundColor(Colors.transparent);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description}");
          },
        ),
      );

    // Load the URL
    await _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(  // Wrap the body in SafeArea
        child: Stack(
          children: [
            WebViewWidget(controller: _controller), // Use WebViewWidget
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
