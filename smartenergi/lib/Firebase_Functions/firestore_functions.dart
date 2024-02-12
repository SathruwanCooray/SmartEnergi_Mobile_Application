import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void addDataToFirestore(String hardwareID, int energyLimit, TimeOfDay nighttimer,String userName) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('User-Settings');

    String documentId = user.uid; 

    Map<String, dynamic> timeMap = {
      'hours': nighttimer.hour,
      'minutes': nighttimer.minute,
    };

    Map<String, dynamic> data = {
      'Username' : userName,
      'Hardware_ID': hardwareID,
      'Energy_Limit': energyLimit,
      'Timer': timeMap,
    };

    collectionReference.doc(documentId).set(data).then((value) {
      print("Data added successfully!");
    }).catchError((error) {
      print("Failed to add data: $error");
    });
  } else {
    print("User not authenticated");
  }
}

void addEnergyLimitToFirebase(int energyLimit) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      CollectionReference userSettings = FirebaseFirestore.instance.collection('User-Settings');

      DocumentSnapshot userDocument = await userSettings.doc(user.uid).get();

      if (userDocument.exists) {
        await userSettings.doc(user.uid).update({
          'Energy_Limit': energyLimit,
        });
      } else {
        await userSettings.doc(user.uid).set({
          'Energy_Limit': energyLimit,
        });
      }
    } catch (error) {
      print("Error adding energy limit to Firestore: $error");
    }
  }
}

void addHardwareIDToFirebase(String hardwareID) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      CollectionReference userSettings = FirebaseFirestore.instance.collection('User-Settings');

      DocumentSnapshot userDocument = await userSettings.doc(user.uid).get();

      if (userDocument.exists) {
        await userSettings.doc(user.uid).update({
          'Hardware_ID': hardwareID,
        });
      } else {
        await userSettings.doc(user.uid).set({
          'Hardware_ID': hardwareID,
        });
      }
    } catch (error) {
      print("Error adding hardware ID to Firestore: $error");
    }
  }
}

void addTimerToFirebase(TimeOfDay timer) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      CollectionReference userSettings = FirebaseFirestore.instance.collection('User-Settings');

      DocumentSnapshot userDocument = await userSettings.doc(user.uid).get();

      Map<String, dynamic> timeMap = {
        'hours': timer.hour,
        'minutes': timer.minute,
      };

      if (userDocument.exists) {
        await userSettings.doc(user.uid).update({
          'Timer': timeMap,
        });
      } else {
        await userSettings.doc(user.uid).set({
          'Timer': timeMap,
        });
      }
    } catch (error) {
      print("Error adding Night Timer to Firestore: $error");
    }
  }
}

Future<String> addDeviceFirebase(String deviceName) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String userUid = user.uid;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference userSettings = firestore.collection('User-Settings');
    final CollectionReference espDevices = firestore.collection("ESP-Devices");

    try {
      DocumentSnapshot userSnapshot = await userSettings.doc(userUid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('Hardware_ID')) {
          String hardwareId = userData['Hardware_ID'];

          DocumentReference deviceRef = espDevices.doc(hardwareId).collection('Devices').doc(deviceName.toUpperCase());

          // Check if the device with the same name already exists
          DocumentSnapshot deviceSnapshot = await deviceRef.get();
          if (deviceSnapshot.exists) {
            return "Name already Exists";
          } else {
            await deviceRef.set({'random': 'random'});
            return "Device $deviceName added successfully under hardware ID $hardwareId.";
          }
        } else {
          return 'User data does not contain hardware ID.';
        }
      } else {
        return 'User data document does not exist.';
      }
    } catch (e) {
      print('Error adding device: $e');
      return 'Error adding device: $e';
    }
  } else {
    return 'User is not authenticated.';
  }
}

Future<String> removeDeviceFirebase(String deviceName) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String userUid = user.uid;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference userSettings = firestore.collection('User-Settings');
    final CollectionReference espDevices = firestore.collection("ESP-Devices");

    try {
      DocumentSnapshot userSnapshot = await userSettings.doc(userUid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('Hardware_ID')) {
          String hardwareId = userData['Hardware_ID'];

          DocumentReference deviceRef = espDevices.doc(hardwareId).collection('Devices').doc(deviceName.toUpperCase());

          // Check if the device exists before attempting to remove it
          DocumentSnapshot deviceSnapshot = await deviceRef.get();
          if (deviceSnapshot.exists) {
            // Device exists, proceed with removal
            await deviceRef.delete();
            return "Device $deviceName removed successfully from hardware ID $hardwareId.";
          } else {
            // Device does not exist
            return "Device $deviceName does not exist.";
          }
        } else {
          return 'User data does not contain hardware ID.';
        }
      } else {
        return 'User data document does not exist.';
      }
    } catch (e) {
      print('Error removing device: $e');
      return 'Error removing device: $e';
    }
  } else {
    return 'User is not authenticated.';
  }
}

