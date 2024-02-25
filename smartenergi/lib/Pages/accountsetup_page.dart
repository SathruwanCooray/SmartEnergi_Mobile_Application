import 'package:flutter/material.dart';
import 'package:smartenergi/Firebase_Functions/firestore_functions.dart';
import 'package:smartenergi/Pages/home_screen.dart';

class ProfileSettingUpPage extends StatefulWidget {
  final String userName;

  const ProfileSettingUpPage({Key? key, required this.userName})
      : super(key: key);

  @override
  State<ProfileSettingUpPage> createState() => _ProfileSettingUpPageState();
}

class _ProfileSettingUpPageState extends State<ProfileSettingUpPage> {
  TimeOfDay nightTimer = const TimeOfDay(hour: 22, minute: 30);
  TextEditingController energyLimitController =
      TextEditingController(text: '1000');
  TextEditingController hardwareIdController = TextEditingController();
  String energyLimit = "1000 KWH";
  bool invalidHardwareID = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Material(
          child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Setting up your profile",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 239, 239, 239),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Pick Device Night Timer",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${nightTimer.hour}:${nightTimer.minute}",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 50,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final TimeOfDay? timeOfDay =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: nightTimer,
                                  initialEntryMode: TimePickerEntryMode.dial,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        primaryColor: Colors.black,
                                        hintColor: Colors.white,
                                        colorScheme: const ColorScheme.light(
                                            primary: Colors.black),
                                        buttonTheme: const ButtonThemeData(
                                          textTheme: ButtonTextTheme.primary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (timeOfDay != null) {
                                  setState(() {
                                    nightTimer = timeOfDay;
                                  });
                                }
                              },
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    const Size(300, 60)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                              ),
                              child: const Text(
                                "Choose Time",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 239, 239, 239),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Pick Device Energy Limit",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              energyLimit,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 50,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Enter Energy Limit"),
                                      content: TextFormField(
                                        controller: energyLimitController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: "Enter energy limit in KWH",
                                        ),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              energyLimit =
                                                  "${energyLimitController.text} KWH";
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Set",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Cancel",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    const Size(300, 60)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                              ),
                              child: const Text(
                                "Choose Energy Limit",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 239, 239, 239),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Enter HardWare ID",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              hardwareIdController.text,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 50,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Enter Hardware ID"),
                                      content: TextFormField(
                                        controller: hardwareIdController,
                                        decoration: const InputDecoration(
                                          hintText: "Enter hardware ID",
                                        ),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            String result =
                                                await checkForHardwareID(
                                                    hardwareIdController.text);
                                            if (result == "Exists") {
                                              invalidHardwareID = false;
                                              print("Valid Hardware ID");
                                              setState(() {
                                                hardwareIdController.text =
                                                    hardwareIdController.text;
                                              });
                                            } else {
                                              invalidHardwareID = true;
                                              print("Invalid Hardware ID");
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                      'Invalid Hardware ID',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'Poppins',
                                                          fontSize: 20)),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Submit",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Cancel",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    const Size(300, 60)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                              ),
                              child: const Text(
                                "Enter HardWare ID",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (invalidHardwareID == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('Invalid Hardware ID',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      fontSize: 20)),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          addDataToFirestore(
                            hardwareIdController.text,
                            int.parse(energyLimitController.text),
                            nightTimer,
                            widget.userName,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                          );
                        }
                      },
                      style: ButtonStyle(
                        minimumSize:
                            MaterialStateProperty.all(const Size(300, 60)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      child: const Text(
                        "SUBMIT",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
