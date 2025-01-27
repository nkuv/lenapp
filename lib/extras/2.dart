import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  bool isLoading = true;
  bool _isControllerInitialized = false;
  final String url = 'https://www.lenienttree.com';
  bool _hasNetwork = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      _hasNetwork = await _checkNetworkConnection();
      debugPrint("Network available: $_hasNetwork");

      await _loadContent();
    } catch (e) {
      debugPrint("Error initializing WebView: $e");
      _showNetworkError();
    }
  }

  Future<bool> _checkNetworkConnection() async {
    bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;
    if (isConnected) {
      try {
        final response = await http.get(Uri.parse('https://www.google.com')).timeout(
          const Duration(seconds: 5),
        );
        return response.statusCode == 200;
      } catch (e) {
        debugPrint("Internet check failed: $e");
        return false;
      }
    }
    return false;
  }

  Future<void> _loadContent() async {
    if (_hasNetwork) {
      await _loadWebContent();
    } else {
      await _loadCachedContent();
    }
  }

  Future<void> _loadWebContent() async {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                isLoading = true;
              });
            },
            onPageFinished: (String url) async {
              setState(() {
                isLoading = false;
              });
              await _cacheWebContent();
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint("WebView Error: ${error.description}");
            },
          ),
        )
        ..loadRequest(Uri.parse(url));

      setState(() {
        _isControllerInitialized = true;
      });
    } catch (e) {
      debugPrint("Error loading web content: $e");
      _showNetworkError();
    }
  }

  Future<void> _cacheWebContent() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/cached_page.html');
        await file.writeAsString(response.body);
        debugPrint("Page cached successfully.");
      }
    } catch (e) {
      debugPrint("Error caching content: $e");
    }
  }

  Future<void> _loadCachedContent() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/cached_page.html');

      if (await file.exists()) {
        final cachedContent = await file.readAsString();
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.transparent)
          ..loadHtmlString(cachedContent);

        setState(() {
          _isControllerInitialized = true;
          isLoading = false;
        });
      } else {
        debugPrint("No cached content found.");
        _showNetworkError();
      }
    } catch (e) {
      debugPrint("Error loading cached content: $e");
      _showNetworkError();
    }
  }

  void _showNetworkError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Network Error"),
        content: const Text("No internet connection and no cached content available."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeWebView();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (_isControllerInitialized)
              WebViewWidget(controller: _controller),
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}