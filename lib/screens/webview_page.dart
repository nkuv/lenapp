import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool isAccessible = true;
  bool isVersionValid = true;
  final String url = 'https://www.lenienttree.com';
  Timer? _configCheckTimer;

  @override
  void initState() {
    super.initState();
    _startConfigChecker();
  }

  @override
  void dispose() {
    _configCheckTimer?.cancel();
    super.dispose();
  }

  void _startConfigChecker() {
    // Check immediately
    _checkAppAccessibility();

    // Then check every 5 minutes
    _configCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _checkAppAccessibility();
    });
  }

  Future<void> _checkAppAccessibility() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();

      var isAccessible = remoteConfig.getBool("accessable");
      final latestVersion = remoteConfig.getString("latest_version");
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (!mounted) return;

      if (!isAccessible) {
        setState(() => isAccessible = false);
        _showAppBlockedDialog();
        return;
      }

      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        setState(() => isVersionValid = false);
        showUpdateDialog(context, latestVersion);
        return;
      }

      setState(() {
        isAccessible = true;
        isVersionValid = true;
      });
    } catch (e) {
      debugPrint("Config check error: $e");
    }
  }

  bool _isUpdateAvailable(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
        return true;
      } else if (latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }

  void _showAppBlockedDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'App Unavailable',
      desc: 'This app is temporarily inaccessible. Please try again later.',
      btnOkOnPress: () {
        SystemNavigator.pop(); // Exit the app
      },
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  void showUpdateDialog(BuildContext context, String latestVersion) {
    void openPlayStore() async {
      const String playStoreUrl = "https://play.google.com/store/apps/details?id=com.whatsapp";
      if (await canLaunch(playStoreUrl)) {
        await launch(playStoreUrl);
      }
    }

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: "Update Available",
      desc: "A new version ($latestVersion) is available. Please update.",
      btnOkText: "Update Now",
      btnOkOnPress: openPlayStore,
      btnOkColor: Colors.blue,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
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
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      customHeader: Image.asset('assets/images/offline.png', height: 80),
      animType: AnimType.scale,
      title: 'Internet Disconnected',
      desc: 'Please check your internet connection.',
      btnOkText: 'Retry',
      btnOkOnPress: () async {
        setState(() => isLoading = true);
        await Future.delayed(const Duration(milliseconds: 1500));
        _controller?.reload();
        setState(() {
          isOffline = false;
          isLoading = true;
        });
      },
      dismissOnTouchOutside: false,
    ).show();
  }

  void onReceivedError(InAppWebViewController controller, Uri? url, String errorDescription) async {
    debugPrint("WebView Error: $errorDescription");

    if (errorDescription.contains("net::ERR_INTERNET_DISCONNECTED")) {
      setState(() => isOffline = true);
      await Future.delayed(const Duration(milliseconds: 1500));
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
              if (isAccessible && isVersionValid && !isOffline)
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(url)),
                  initialSettings: InAppWebViewSettings(
                    cacheEnabled: true,
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
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
                    String readyState = await controller.evaluateJavascript(
                        source: "document.readyState");

                    injectDisableZoom(controller);

                    if (readyState == 'complete') {
                      setState(() => isLoading = false);
                    } else {
                      await Future.delayed(const Duration(milliseconds: 800));
                      setState(() => isLoading = false);
                    }
                  },
                  onReceivedError: (controller, request, error) {
                    onReceivedError(controller, request.url, error.description);
                  },
                ),
              if (!isAccessible || !isVersionValid)
                Container(
                  color: const Color(0xFF050817),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.white),
                        const SizedBox(height: 20),
                        Text(
                          !isAccessible
                              ? 'App temporarily unavailable'
                              : 'Update required',
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
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