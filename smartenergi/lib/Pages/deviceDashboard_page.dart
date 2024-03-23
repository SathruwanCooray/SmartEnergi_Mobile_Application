import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceDashboard extends StatefulWidget {
  final String deviceName;

  const DeviceDashboard({Key? key, required this.deviceName}) : super(key: key);

  @override
  State<DeviceDashboard> createState() => _DeviceDashboardState();
}

class _DeviceDashboardState extends State<DeviceDashboard> {
  double realTimeValue = 0;
  double realTimeStopped = 0;
  String connectionState = "Disconnected";
  bool isConnected = false;
  late String hardwareId;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    try {
      if (!isConnected) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          return;
        }

        final userUid = currentUser.uid;

        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await firestore.collection('User-Settings').doc(userUid).get();

        if (documentSnapshot.exists) {
          Map<String, dynamic>? userData = documentSnapshot.data();

          if (userData != null && userData.containsKey('Hardware_ID')) {
            hardwareId = userData['Hardware_ID'];

            final espModuleRef = FirebaseDatabase.instance
                .reference()
                .child('ESPmodules')
                .child(hardwareId)
                .child('CurrentValue');

            espModuleRef.onValue.listen((event) async {
              final currentValue = event.snapshot.value as double;
              if (connectionState == "Connected") {
                setState(() {
                  realTimeValue = currentValue;
                  isConnected = true;
                });

                try {
                  await FirebaseFirestore.instance
                      .collection('System-Verified-Modules')
                      .doc('XQCTF')
                      .update({
                    'CurrentlyConnected': widget.deviceName.toUpperCase()
                  });
                } catch (e) {
                  print('Error updating field: $e');
                }
              } else {
                setState(() {
                  isConnected = false;
                  realTimeValue = realTimeStopped;
                });
              }
            });
          }
        } else {
          print('Document does not exist');
        }
      }
    } catch (error) {
      print("Error connecting to device: $error");
    }
  }

  void toggleConnection() {
    if (connectionState == "Disconnected") {
      setState(() {
        connectionState = "Connected";
        isConnected = true; // Update isConnected when connected
      });

      // Perform Firestore update
      FirebaseFirestore.instance
          .collection('System-Verified-Modules')
          .doc('XQCTF')
          .update({
        'CurrentlyConnected': widget.deviceName.toUpperCase()
      }).catchError((error) {
        print('Error updating field: $error');
      });
    } else if (connectionState == "Connected") {
      setState(() {
        connectionState = "Disconnected";
        isConnected = false; // Update isConnected when disconnected
        realTimeValue = 0;
      });

      // Perform Firestore update
      FirebaseFirestore.instance
          .collection('System-Verified-Modules')
          .doc('XQCTF')
          .update({
        'CurrentlyConnected': "NONE"
      }).catchError((error) {
        print('Error updating field: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.deviceName.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                _connectToDevice();
                toggleConnection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected
                    ? const Color.fromARGB(255, 255, 0, 0)
                    : const Color.fromARGB(255, 0, 232, 4),
                minimumSize: const Size(250, 50),
              ),
              child: Text(
                isConnected ? "Disconnect" : "Connect",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 390,
              height: 175,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 227, 227, 227),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Real Time Energy Tracker",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${realTimeValue.toStringAsFixed(2)} Kwh",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
             const SizedBox(
              height: 20,
            ),
            Container(
              width: 390,
              height: 175,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 227, 227, 227),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Real Time Current Flow",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${(realTimeValue/230).toStringAsFixed(2)} A",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),const SizedBox(
              height: 20,
            ),
            Container(
              width: 390,
              height: 175,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 227, 227, 227),
              ),
              child: const Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        " Fixed Voltage",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "230",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
             const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
