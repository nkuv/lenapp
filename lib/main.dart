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
      theme: ThemeData.light(), // Light theme (optional)
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF050817), // Black pearl background
        appBarTheme: AppBarTheme(
          color: Colors.black, // Deep black app bar
        ),
        // You can further customize other dark theme properties here
      ),

      themeMode: ThemeMode.dark, // Set dark mode as default
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
                builder: (context) => const WebViewPage(),
              ),
            );
          },
          child: const Text('Open WebView'),
        ),
      ),
    );
  }
}

