import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'webview_page.dart';

class TermsPage extends StatefulWidget {
  final VoidCallback onAccepted;

  const TermsPage({required this.onAccepted, super.key});

  @override
  _TermsPageState createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  String _htmlContent = "";
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    loadHtmlContent();
  }

  Future<void> loadHtmlContent() async {
    String content = await rootBundle.loadString('assets/terms.html');
    if (mounted) {
      setState(() {
        _htmlContent = content;
      });
    }
  }

  Future<void> _acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('termsAccepted', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WebViewPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: Column(
        children: [
          Expanded(
            child: _htmlContent.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : InAppWebView(
              initialData: InAppWebViewInitialData(data: _htmlContent),
            ),
          ),
          CheckboxListTile(
            value: _accepted,
            onChanged: (val) {
              if (mounted) {
                setState(() => _accepted = val ?? false);
              }
            },
            title: const Text("I agree to the Terms & Conditions"),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _accepted ? _acceptTerms : null,
              child: const Text("Accept & Continue"),
            ),
          ),
        ],
      ),
    );
  }
}