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
  final String url = 'https://www.lenienttree.com';

  @override
  void initState() {
    super.initState();
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
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                ),
                onWebViewCreated: (controller) {
                  _controller = controller;
                },
                onLoadStart: (InAppWebViewController controller, Uri? url) {
                  setState(() {
                    isLoading = true;
                  });
                },
                onLoadStop: (InAppWebViewController controller, Uri? url) async {
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
                  debugPrint("WebView Error: \${error.description}");
                },
              ),
              buildLoadingAnimation(isLoading: isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
