import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smartenergi/Firebase_Functions/local_Notification.dart';
import 'package:smartenergi/Pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAygTXVYk-30pA_9-Kar_CZxlxiCjsrzzc",
      appId: "1:243668481623:android:b2860e65f89ff35afb1512",
      messagingSenderId: "243668481623",
      projectId: "smartenergi-56048",
    ),
  );

  await LocalNotifications.init();
  // Fetch timer data and check for user every 10 seconds
  Timer.periodic(Duration(seconds: 30), (timer) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _fetchTimer(user.uid);
    }
  });

  runApp(const MyApp());
}

// Define a variable to store the last time a notification was sent
DateTime? lastNotificationTime;

Future<void> _fetchTimer(String userId) async {
  try {
    DocumentSnapshot userSettingsSnapshot = await FirebaseFirestore.instance
        .collection('User-Settings')
        .doc(userId)
        .get();

    // Get timer data
    Map<String, dynamic>? timerData = userSettingsSnapshot['Timer'];

    // Check if the field value is 'NONE'
    DocumentSnapshot systemModuleSnapshot = await FirebaseFirestore.instance
        .doc('/System-Verified-Modules/XQCTF')
        .get();

    // Explicitly cast data to Map<String, dynamic>
    Map<String, dynamic>? systemModuleData =
        systemModuleSnapshot.data() as Map<String, dynamic>?;

    // Perform null and type checking before accessing the value
    dynamic currentlyConnected = systemModuleData?['CurrentlyConnected'];
    if (currentlyConnected is String && currentlyConnected != 'NONE') {
      // Get current time
      DateTime now = DateTime.now();

      // Check if timer is fetched and current time matches fetched time
      if (timerData != null &&
          timerData['hours'] != null &&
          timerData['minutes'] != null &&
          now.hour == timerData['hours'] &&
          now.minute.toString() == timerData['minutes']) {
        // Check if notification for this time has already been sent
        if (lastNotificationTime == null ||
            lastNotificationTime!.hour != now.hour ||
            lastNotificationTime!.minute != now.minute) {
          // Trigger notification
          LocalNotifications.showSimpleNotification(
            title: 'Reminder: Connected Device is on',
            body: 'Disconnect the conncted device',
            payload: 'Timer_notification',
          );

          // Update last notification time
          lastNotificationTime = now;

          print('Notification sent at ${now.hour}:${now.minute}');
        } else {
          print('Notification already sent for ${now.hour}:${now.minute}');
        }
      }
    }

    print('Fetched Timer: $timerData');
  } catch (error) {
    print("Error fetching timer data: $error");
  }
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
