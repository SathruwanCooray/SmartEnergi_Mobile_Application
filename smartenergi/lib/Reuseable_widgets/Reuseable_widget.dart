import 'package:flutter/material.dart';

TextField reusableTextField(
  String text,
  IconData icon,
  bool isPasswordType,
  TextEditingController controller,
  String? errorText,
) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: const Color.fromARGB(255, 0, 0, 0),
    style: TextStyle(
      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
    ),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: const Color.fromARGB(179, 0, 0, 0)),
      labelText: text,
      labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none)
      ),
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.red),
    ),
    keyboardType: isPasswordType ? TextInputType.visiblePassword : TextInputType.emailAddress,
  );
}

Container signUpButton(
    BuildContext context, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(
      borderRadius:
          BorderRadius.circular(30), // Corrected the borderRadius value
    ),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return const Color.fromARGB(255, 255, 255, 255);
          }
          return const Color.fromARGB(255, 0, 0, 0);
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      child: const Text('SIGN UP',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.w500,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
    ),
  );
}


