import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // For SystemChrome
import 'screens/splash_screen.dart';  // Import the splash screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _setNavigationBarColor();  // Set the navigation bar color when the app starts
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lenient Tree',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050817),
        appBarTheme: const AppBarTheme(
          color: Colors.black,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),  // Show splash screen as the home
    );
  }
}

void _setNavigationBarColor() {
  // Set the navigation bar color to a custom color (e.g., Blue)
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: const Color(0xFF050817),  // Set your desired color
    systemNavigationBarIconBrightness: Brightness.light,  // Optional: Set icon brightness
  ));
}
