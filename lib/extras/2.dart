import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String latestVersion = "Unknown";
  String currentVersion = "Unknown";

  @override
  void initState() {
    super.initState();
    checkForUpdate();
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

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      currentVersion = packageInfo.version;

      print("🔄 Latest version from Remote Config: $latestVersion");
      print("📱 Current app version: $currentVersion");

      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        showUpdateDialog(context,latestVersion);
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

  void showUpdateDialog(BuildContext context,String latestVersion) {
    void openPlayStore() async{
      final String playStoreUrl = "https://play.google.com/store/apps/details?id=com.whatsapp";

      if (await canLaunch(playStoreUrl)) {
        await launch(playStoreUrl);
      } else {
        print("❌ Could not launch Play Store ");
      }
      // Add logic to open Play Store link
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
