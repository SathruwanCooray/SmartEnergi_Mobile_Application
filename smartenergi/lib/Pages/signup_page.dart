import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartenergi/Pages/accountsetup_page.dart';
import 'package:smartenergi/Pages/signin_page.dart';
import 'package:smartenergi/Reuseable_widgets/Reuseable_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _nameTextController = TextEditingController();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;

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
                    "Create your account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  reusableTextField(
                    "Enter your name",
                    Icons.person_outline,
                    false,
                    _nameTextController,
                    null,
                  ),
                  const SizedBox(height: 20),
                  reusableTextField(
                    "Enter Email",
                    Icons.person_outline,
                    false,
                    _emailTextController,
                    _isEmailValid ? null : 'Invalid email format',
                  ),
                  const SizedBox(height: 20),
                  reusableTextField(
                    "Enter Password",
                    Icons.lock_outline,
                    true,
                    _passwordTextController,
                    _isPasswordValid
                        ? null
                        : 'Password must be more than 6 Characters',
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  signUpButton(
                    context,
                    () {
                      String email = _emailTextController.text.trim();
                      String password = _passwordTextController.text.trim();

                      bool email0 = _isValidEmail(email);
                      bool password0 = _isPasswordCharacters(password);

                      setState(() {
                        _isEmailValid = email0;
                        _isPasswordValid = password0;
                      });

                      if (!_isEmailValid || !_isPasswordValid) {
                        return;
                      }

                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: email, password: password)
                          .then((value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileSettingUpPage(
                                  userName: _nameTextController.text.trim())),
                        );
                      }).onError((error, stackTrace) {
                        print("Error ${error.toString()}");
                      });
                    },
                  ),
                  signInOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row signInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
            );
          },
          child: const Text(
            " Login",
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

  bool _isPasswordCharacters(String password) {
    if (password.length > 6) {
      return true;
    } else {
      return false;
    }
  }
}
