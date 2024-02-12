import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartenergi/Pages/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyC1KG32Ki-Mqkk2Hs1ZiJGbVX0MFJUvjbY",
    appId: "1:483460245150:android:26a8a48dcc031cecb7bd8f",
    messagingSenderId: "483460245150",
    projectId: "smartenergi-7425c"));
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