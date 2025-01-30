import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../utils/webview_utils.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _controller;
  bool isLoading = true;
  bool isOffline = false;
  final String url = 'https://www.lenienttree.com';

  @override
  void initState() {
    super.initState();
  }

  Widget buildLoadingAnimation() {
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

  void showOfflineDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue.shade900,
          title: Text(
            'Internet Disconnected',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Please check your internet connection.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                Navigator.of(context).pop();
                await Future.delayed(const Duration(seconds: 2));
                _controller?.reload();
                setState(() {
                  isOffline = false;
                  isLoading = true;
                });
              },
              child: Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void onReceivedError(InAppWebViewController controller, Uri? url, String errorDescription) async {
    debugPrint("WebView Error: $errorDescription");

    if (errorDescription.contains("net::ERR_INTERNET_DISCONNECTED")) {
      setState(() {
        isOffline = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      showOfflineDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_controller != null && await _controller!.canGoBack()) {
          _controller!.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Visibility(
                visible: !isOffline,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(url)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                  ),
                  onWebViewCreated: (controller) {
                    _controller = controller;
                    injectDisableZoom(controller);
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      isLoading = true;
                      isOffline = false;
                    });
                  },
                  onLoadStop: (controller, url) async {
                    String readyState = await controller.evaluateJavascript(source: "document.readyState");

                    injectDisableZoom(controller);

                    if (readyState == 'complete') {
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
                  onReceivedError: (controller, request, error) {
                    onReceivedError(controller, request.url, error.description);
                  },
                ),
              ),
              if (isOffline || isLoading) buildLoadingAnimation(),
            ],
          ),
        ),
      ),
    );
  }
}
