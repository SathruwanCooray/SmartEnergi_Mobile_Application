import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartenergi/Firebase_Functions/firestore_functions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late FirebaseFirestore _firestore;
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> timer = {};

  String username = ""; 
  late TimeOfDay selectedNightTimer;
  int energyLimit = 0; 
  String hardwareId = "";

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    selectedNightTimer = const TimeOfDay(hour: 00, minute: 00);
    if (user != null) {
      _fetchUserData(user?.uid ?? '');
    }
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot userSettingsSnapshot =
          await _firestore.collection('User-Settings').doc(userId).get();

      String fetchedUsername = userSettingsSnapshot['Username'];
      int fetchEnergyLimit = userSettingsSnapshot['Energy_Limit'];
      String fetchHardwareID = userSettingsSnapshot['Hardware_ID'];
      Map<String, dynamic> fetchTimer = userSettingsSnapshot['Timer'];

      setState(() {
        username = fetchedUsername;
        energyLimit = fetchEnergyLimit;
        hardwareId = fetchHardwareID;
        timer = fetchTimer; 
        selectedNightTimer = TimeOfDay(
          hour: timer['hours'] ?? 0,
          minute: timer['minutes'] ?? 0,
        );
      });
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  Future<void> _selectNightTimer(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedNightTimer,
    );
    if (picked != null && picked != selectedNightTimer) {
      addTimerToFirebase(picked); 
      setState(() {
        selectedNightTimer = picked;
      });
    }
  }


  Future<void> _selectEnergyLimit(BuildContext context) async {
    final TextEditingController limitController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Energy Limit"),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter Limit"),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  addEnergyLimitToFirebase(int.parse(limitController.text));
                  energyLimit = int.tryParse(limitController.text) ?? 0;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectHardwareId(BuildContext context) async {
    final TextEditingController hardwareIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Hardware ID"),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: hardwareIdController,
              decoration: const InputDecoration(labelText: "Enter Hardware ID"),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  addHardwareIDToFirebase(hardwareIdController.text);
                  hardwareId = hardwareIdController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 40, top: 16, bottom: 16),
                    child: const Text(
                      "User Profile",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 30,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Hello $username!",
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 30, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Text(
                            "Night Timer",
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          
                          Text("${selectedNightTimer.hour}:${selectedNightTimer.minute}", style: const TextStyle(fontSize: 30, fontFamily: 'Poppins', fontWeight: FontWeight.w600),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _selectNightTimer(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black,
                      ),
                      child: const Text("Select Time", style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Text(
                            "Energy Limit Picker",
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text("$energyLimit KwH",style: const TextStyle(fontSize: 30, fontFamily: 'Poppins', fontWeight: FontWeight.w600),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _selectEnergyLimit(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black,
                      ),
                      child: const Text("Set Limit", style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Text(
                            "Hardware IDE Picker",
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(hardwareId, style: const TextStyle(fontSize: 30, fontFamily: 'Poppins', fontWeight: FontWeight.w600),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        _selectHardwareId(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black,
                      ),
                      child: const Text("Set Hardware ID", style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),),
                    ),
                  ],
                ),
              ),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
