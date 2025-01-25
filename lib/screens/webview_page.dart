import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    final controller = WebViewController();

    // Set WebView options like disabling zoom
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) async {
          setState(() {
            isLoading = true;
          });
        },
        onPageFinished: (String url) async {
          setState(() {
            isLoading = false;
          });
          controller.setBackgroundColor(Colors.transparent);
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint("WebView Error: ${error.description}");
        },
      ),
    );
    // Load URL
    await controller.loadRequest(Uri.parse(url));
    // Set the WebView controller
    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(  // Wrap the body in SafeArea
        child: Stack(
          children: [
            WebViewWidget(
              controller: _controller,
            ),
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
