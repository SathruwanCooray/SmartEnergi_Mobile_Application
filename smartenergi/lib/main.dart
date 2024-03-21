import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartenergi/Pages/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyAygTXVYk-30pA_9-Kar_CZxlxiCjsrzzc",
    appId: "1:243668481623:android:b2860e65f89ff35afb1512",
    messagingSenderId: "243668481623",
    projectId: "smartenergi-56048"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMARTENERGI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}