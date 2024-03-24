import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smartenergi/Firebase_Functions/local_Notification.dart';
import 'package:smartenergi/Pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyAygTXVYk-30pA_9-Kar_CZxlxiCjsrzzc",
    appId: "1:243668481623:android:b2860e65f89ff35afb1512",
    messagingSenderId: "243668481623",
    projectId: "smartenergi-56048")
  );
  
  await LocalNotifications.init();
  
  Timer.periodic(const Duration(seconds: 5), (timer) {
    checkAndDeleteNoneNode();
  });
  
  runApp(const MyApp());
}

Future<void> checkAndDeleteNoneNode() async {
  DatabaseReference espModulesRef = FirebaseDatabase.instance.reference().child('ESPmodules').child('XQCTF').child('Devices');

  // Listen for changes at the "NONE" node
  espModulesRef.child('NONE').onValue.listen((event) {
    if (event.snapshot.exists) {
      // "NONE" node exists, delete it
      espModulesRef.child('NONE').remove();
      print('Deleted "NONE" node under ESPmodules/XQCTF/DEVICES.');
    } else {
      // "NONE" node doesn't exist
      print('"NONE" node not found under ESPmodules/XQCTF/DEVICES.');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
