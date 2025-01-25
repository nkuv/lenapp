import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key}); // No constructor parameter for URL

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller; // WebViewController instance
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    const String url = 'https://www.lenienttree.com';
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
            _controller.setBackgroundColor(Colors.transparent);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(url)); // Use the declared URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView Page'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller,),
          // Load the WebView content
          if (isLoading)
            const Center(child: CircularProgressIndicator()), // Show progress indicator
        ],
      ),
    );
  }
}
