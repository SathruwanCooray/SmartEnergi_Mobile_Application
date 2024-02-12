import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartenergi/Pages/home_screen.dart';
import 'package:smartenergi/Pages/signup_page.dart';
import 'package:smartenergi/Reuseable_widgets/Reuseable_widget.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  bool _isEmailValid = true; 
  bool _isPasswordValid = true; 
  String _errorMessage = ""; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Login to your account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  reusableTextField(
                    "Enter Email",
                    Icons.person_outline,
                    false,
                    _emailTextController,
                    _isEmailValid ? null : 'Invalid email format',
                  ),
                  const SizedBox(height: 5),  
                  _isPasswordValid
                      ? Container()  
                      : Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                  const SizedBox(height: 20),
                  reusableTextField(
                    "Enter Password",
                    Icons.lock_outline,
                    true,
                    _passwordTextController,
                    null,
                  ),
                  _isPasswordValid
                      ? Container()  
                      : Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        String email = _emailTextController.text.trim();
                        String password = _passwordTextController.text.trim();
                    
                        if (!_isValidEmail(email)) {
                          setState(() {
                            _isEmailValid = false;
                            _errorMessage = 'Invalid email format';
                          });
                          return;
                        }
                    
                        setState(() {
                          _isEmailValid = true;
                          _errorMessage = '';
                        });
                    
                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                        } catch (error) {
                          print("Error: $error");
                          String errorMessage = "Invalid email or password";  
                    
                          if (error is FirebaseAuthException) {
                            if (error.code == 'user-not-found') {
                              errorMessage = "User not found";
                            } else if (error.code == 'wrong-password') {
                              errorMessage = "Wrong password";
                            }
                          }
                    
                          
                          setState(() {
                            _isPasswordValid = false;
                            _errorMessage = errorMessage;
                          });
                        }
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
                        elevation: MaterialStateProperty.all(5), 
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height:20),
                  signUpOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpPage()),
            );
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }
}
