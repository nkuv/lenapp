import 'package:flutter/material.dart';
import 'dart:async';
import 'webview_page.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  String latestVersion = "Unknown";
  String currentVersion = "Unknown";
  bool accessable = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: 900), () {
      _controller.forward();
    });

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    checkForUpdate();

    Timer(Duration(milliseconds: 2700), () {
      // Proceed to WebViewPage after animation and update check
      if (latestVersion != currentVersion) {
        return; // Do not navigate if update is required
      }
      if (!accessable){
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WebViewPage()),
      );
    });
  }

  Future<void> checkForUpdate() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // Force fetch every time
      ));

      await remoteConfig.fetchAndActivate();

      latestVersion = remoteConfig.getString("latest_version");
      bool isAccessible = remoteConfig.getBool("accessable");
      accessable = isAccessible;

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      currentVersion = packageInfo.version;

      print("🔄 Latest version from Remote Config: $latestVersion");
      print("📱 Current app version: $currentVersion");
      print("✅ App accessible: $isAccessible");

      if (!isAccessible) {
        showAppBlockedDialog(context); // Prevent access if not accessible
        return;
      }

      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        showUpdateDialog(context, latestVersion);
      }
    } catch (e) {
      print("❌ Error fetching Remote Config: $e");
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

  void showUpdateDialog(BuildContext context, String latestVersion) {
    void openPlayStore() async {
      final String playStoreUrl = "https://play.google.com/store/apps/details?id=com.whatsapp";

      if (await canLaunch(playStoreUrl)) {
        await launch(playStoreUrl);
      } else {
        print("❌ Could not launch Play Store ");
      }
    }

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info, // Info icon for updates
      animType: AnimType.scale, // Smooth scale animation
      title: "Update Available",
      desc: "A new version ($latestVersion) is available. Please update.",
      btnCancelText: "Later",
      btnCancelOnPress: () {}, // Simply dismisses the dialog
      btnOkText: "Update Now",
      btnOkOnPress: openPlayStore, // Opens Play Store link
      btnOkColor: Colors.blue, // Highlight "Update Now" button
      dismissOnTouchOutside: false, // Prevents accidental dismiss
    ).show();
  }

  void showAppBlockedDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'App Unavailable',
      desc: 'This app is temporarily inaccessible. Please try again later.',
      btnOkOnPress: () {
        // Optionally exit the app or disable navigation
      },
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050817),
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Text(
            'Lenient Tree',
            style: TextStyle(
              fontFamily: 'LexendDeca',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
