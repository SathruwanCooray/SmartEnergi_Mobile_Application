import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartenergi/Pages/deviceDashboard_page.dart';
import 'package:smartenergi/Pages/profile_page.dart';
import 'package:smartenergi/Pages/signin_page.dart';
import 'package:smartenergi/Firebase_Functions/firestore_functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> devices = [];
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDevicesFromFirebase();
  }

  Future<void> getDevicesFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userUid = user.uid;

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference userSettings =
          firestore.collection('User-Settings');
      final CollectionReference espDevices =
          firestore.collection("ESP-Devices");

      try {
        DocumentSnapshot userSnapshot = await userSettings.doc(userUid).get();

        if (userSnapshot.exists) {
          Map<String, dynamic>? userData =
              userSnapshot.data() as Map<String, dynamic>?;

          if (userData != null && userData.containsKey('Hardware_ID')) {
            String hardwareId = userData['Hardware_ID'];

            QuerySnapshot devicesSnapshot =
                await espDevices.doc(hardwareId).collection('Devices').get();

            setState(() {
              devices = devicesSnapshot.docs.map((doc) => doc.id).toList();
            });
            print(devices);
          }
        }
      } catch (error) {
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScaffoldMessenger(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 20,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child:
                                Icon(Icons.account_circle, color: Colors.white),
                          ),
                        ),
                        const Text(
                          'SMARTENERGI',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut().then((value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignInPage(),
                                ),
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(Icons.exit_to_app, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: devices.asMap().entries.map((entry) {
                          int index = entry.key;
                          String deviceName = entry.value;
                          return deviceDisplay(deviceName, index);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 16.0,
                right: 0.0,
                left: 0.0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FloatingActionButton(
                    onPressed: () {
                      _addDeviceDialog(context);
                    },
                    backgroundColor: Colors.black,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addDeviceDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Device'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              hintText: "Enter device name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String deviceName = _textEditingController.text;
                if (deviceName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        'Please enter a device name.',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 20),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );

                } else {
                  await _addDevice(deviceName);
                  _textEditingController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addDevice(String deviceName) async {
    try {
      String result = await addDeviceFirebase(deviceName);
      setState(() {
        if (result != "Name already Exists") {
          devices.add(deviceName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Device with the same name already exists.',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Poppins', fontSize: 20),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding device: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget deviceDisplay(String deviceName, int index) {
    return Dismissible(
      key: Key('$deviceName$index'),
      onDismissed: (direction) {
        setState(() {
          devices.removeAt(index);
          removeDeviceFirebase(deviceName);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: const Color.fromARGB(255, 227, 227, 227),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              deviceName.toUpperCase(),
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontFamily: 'Poppins',
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DeviceDashboard(deviceName: deviceName),
                        ),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text('View',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        devices.removeAt(index);
                        removeDeviceFirebase(deviceName);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 210, 0, 0)),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Color.fromARGB(255, 89, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
