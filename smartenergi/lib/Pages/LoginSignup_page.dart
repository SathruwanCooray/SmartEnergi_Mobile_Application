import 'package:flutter/material.dart';
import 'package:smartenergi/Pages/signin_page.dart';
import 'package:smartenergi/Pages/signup_page.dart';

class loginSignupPage extends StatefulWidget {
  const loginSignupPage({Key? key}) : super(key: key);

  @override
  State<loginSignupPage> createState() => _loginSignupPageState();
}

class _loginSignupPageState extends State<loginSignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Adjust roundness here
                ),
                minimumSize: Size(300, 60), // Adjust width and height here
                backgroundColor: Colors.black, // Set button color to black
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white, // Set text color to white
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 30), // Adding some space between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInPage()));
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Adjust roundness here
                ),
                minimumSize: Size(300, 60), // Adjust width and height here
                backgroundColor: Colors.black, // Set button color to black
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white, // Set text color to white
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
