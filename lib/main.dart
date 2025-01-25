import 'package:flutter/material.dart';
import 'screens/webview_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // Add const and key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lenient Tree',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});  // Add const and key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewPage(url: 'https://www.lenienttree.com'),
              ),
            );
          },
          child: const Text('Open WebView'),
        ),
      ),
    );
  }
}
