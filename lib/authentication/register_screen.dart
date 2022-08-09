import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../components/awesome_dialog.dart';
import '../components/loading_dialog.dart';
import '../screens/home_screen.dart';
import '../components/background.dart';
import 'login_screen.dart';
import 'set_password_for_google_screen.dart';
import 'verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  late String name, email, password;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Background(),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        bottom: size.height * .10, top: size.height * .23),
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 43, 91),
                        fontSize: size.width * .11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * .28,
                    child: Stack(
                      children: [
                        Container(
                          height: size.height * .28,
                          margin: EdgeInsets.only(
                            right: size.width * .15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * .30),
                              bottomRight: Radius.circular(size.width * .30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: size.width * .03,
                              ),
                            ],
                          ),
                          child: Form(
                            key: formState,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      left: size.width * .04,
                                      right: size.width * .15),
                                  child: TextFormField(
                                    onSaved: (val) {
                                      name = val!;
                                    },
                                    validator: (val) {
                                      if (val!.length > 100) {
                                        return "Name can't be more than 100 letter";
                                      } else if (val.length < 3) {
                                        return "Username can't be less than 3 letter";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 43, 91),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        Icons.person_outline,
                                        color: Color.fromARGB(255, 0, 43, 91),
                                      ),
                                      hintText: "Name",
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: size.width * .04,
                                      right: size.width * .15),
                                  child: TextFormField(
                                    onSaved: (val) {
                                      email = val!;
                                    },
                                    validator: (val) {
                                      if (!EmailValidator.validate(val!)) {
                                        return "Email is Not Valid";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 43, 91)),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(Icons.email_outlined,
                                          color:
                                              Color.fromARGB(255, 0, 43, 91)),
                                      hintText: "Email",
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: size.width * .04,
                                      right: size.width * .15),
                                  child: TextFormField(
                                    onSaved: (val) {
                                      password = val!;
                                    },
                                    validator: (val) {
                                      if (val!.length > 100) {
                                        return "Password can't be more than 100 letter";
                                      } else if (val.length < 8) {
                                        return "Password can't be less than 8 letter";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 43, 91)),
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(Icons.password_outlined,
                                          color:
                                              Color.fromARGB(255, 0, 43, 91)),
                                      hintText: "Password",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () async {
                              await signUpWithEmailAndPassword();
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: size.width * .04),
                              height: size.height * .20,
                              width: size.width * .20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color.fromARGB(255, 37, 109, 133),
                                    Color.fromARGB(255, 0, 43, 91),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_outlined,
                                color: Colors.white,
                                size: size.width * .08,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: size.width * .04, top: size.height * .02),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Login",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: size.width * .055,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 0, 43, 91),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: size.height * .02, bottom: size.height * .02),
                    child: SignInButton(
                      Buttons.google,
                      onPressed: () async {
                        await signInWithGoogle();
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  signUpWithEmailAndPassword() async {
    var formData = formState.currentState;
    if (formData!.validate()) {
      formData.save();
      showLoadingDialog(context);

      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty){
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
              .then((userValue) {
            userValue.user!.updateDisplayName(name);

            FirebaseFirestore.instance.collection("users").add({
              "withPassword": true,
              "uId": userValue.user!.uid,
            }).then((value) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VerificationScreen(),
                  ),
                      (route) => false);
            }).catchError((e) {
              Navigator.pop(context);
              showAwesomeDialog(context, e.toString());
            });
          }).catchError((e) {
            Navigator.pop(context);
            if (e.toString().contains("weak-password")) {
              showAwesomeDialog(context, "The Password is too weak");
            } else if (e.toString().contains("email-already-in-use")) {
              showAwesomeDialog(
                  context, "The account already exists for that email");
            } else {
              showAwesomeDialog(context, e.toString());
            }
          });
        }
      } on SocketException{
        Navigator.pop(context);
        showAwesomeDialog(context, "No Internet Connection");
      }


    }
  }

  signInWithGoogle() async {

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        await GoogleSignIn().signIn().then((googleUser) async {
          await googleUser!.authentication.then((googleAuth) {
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            FirebaseAuth.instance.signInWithCredential(credential).then((user) {
              FirebaseFirestore.instance
                  .collection("users")
                  .where("uId", isEqualTo: user.user!.uid)
                  .get()
                  .then((value) {
                if (value.docs.isEmpty) {
                  FirebaseFirestore.instance.collection("users").add({
                    "withPassword": false,
                    "uId": user.user!.uid,
                  }).then((value) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SetPasswordForGoogleScreen(),
                        ),
                            (route) => false);
                  }).catchError((e) {
                    showAwesomeDialog(context, e.toString());
                  });
                } else {
                  for (var element in value.docs) {
                    if (element.data()["withPassword"]) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                              (route) => false);
                    } else {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const SetPasswordForGoogleScreen(),
                          ),
                              (route) => false);
                    }
                  }
                }
              }).catchError((e) {
                showAwesomeDialog(context, e.toString());
              });
            }).catchError((e) {
              showAwesomeDialog(context, e.toString());
            });
          }).catchError((e) {
            showAwesomeDialog(context, e.toString());
          });
        }).catchError((e) {
          showAwesomeDialog(context, e.toString());
        });
      }
    } on SocketException{
      Navigator.pop(context);
      showAwesomeDialog(context, "No Internet Connection");
    }



  }
}
