import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/webview_utils.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool isLoading = true;
  final String url = 'https://www.lenienttree.com';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

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
          onPageFinished: (String url) async {
            bool resourcesLoaded = await _controller.runJavaScriptReturningResult(
                "document.readyState === 'complete'"
            ) == 'true';
            injectDisableZoom(_controller);
            if (resourcesLoaded) {
              setState(() {
                isLoading = false;
              });
            } else {
              await Future.delayed(const Duration(milliseconds: 800));
              setState(() {
                isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description}");
          },
        ),
      );

    await _controller.loadRequest(Uri.parse(url));
  }

  Widget buildLoadingAnimation({required bool isLoading}) {
    return isLoading
        ? Container(
      color: const Color(0xFF050817),
      child: Center(
        child: LoadingAnimationWidget.waveDots(
          color: Colors.white,
          size: 60,
        ),
      ),
    )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              buildLoadingAnimation(isLoading: isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
