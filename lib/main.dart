import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _setNavigationBarColor();
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
      home: const SplashScreen(),
    );
  }
}

void _setNavigationBarColor() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: const Color(0xFF050817),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
}
