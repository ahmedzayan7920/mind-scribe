import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/screens/home_screen.dart';
import 'package:flutterfirebase/authentication/register_screen.dart';
import 'package:flutterfirebase/authentication/set_password_for_google_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../components/loading_dialog.dart';
import 'verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late String email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Form(
                key: formState,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      onSaved: (val) {
                        email = val!;
                      },
                      validator: (val) {
                        if (!EmailValidator.validate(val!)) {
                          return "Email is Not Valid";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Your Email",
                        labelText: 'Email Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      onSaved: (val) {
                        password = val!;
                      },
                      validator: (val) {
                        if (val!.length > 100) {
                          return "Password can't be more than 100 letter";
                        } else if (val.isEmpty) {
                          return "Please Enter your Password";
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Enter Your Password",
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          "Don't Have Account?",
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text("REGISTER"),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await signInWithEmailAndPassword();
                      },
                      child: const Text("LOGIN"),
                    ),
                    const Text("OR LOGIN WITH"),
                    ElevatedButton(
                      onPressed: () async {
                        await signInWithGoogle();
                      },
                      child: const Text("GOOGLE"),
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

  signInWithEmailAndPassword() {
    var formData = formState.currentState;
    if (formData!.validate()) {
      formData.save();
      showLoading(context);
      try {
        FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
            .then((userValue) {
          if (userValue.user!.emailVerified) {
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
                  builder: (context) => const VerificationScreen(),
                ),
                (route) => false);
          }
        }).catchError((e) {
          if (e.code == 'user-not-found') {
            Navigator.pop(context);
            AwesomeDialog(
              context: context,
              title: "Error",
              body: const Text("No user found for that email.",
                  style: TextStyle(fontSize: 24)),
              dismissOnBackKeyPress: false,
              dismissOnTouchOutside: false,
              btnCancel: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              ),
            ).show();
          } else if (e.code == 'wrong-password') {
            Navigator.pop(context);
            AwesomeDialog(
              context: context,
              title: "Error",
              body:
                  const Text("Wrong password", style: TextStyle(fontSize: 24)),
              dismissOnBackKeyPress: false,
              dismissOnTouchOutside: false,
              btnCancel: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              ),
            ).show();
          } else {
            Navigator.pop(context);
            AwesomeDialog(
              context: context,
              title: "Error",
              body: const Text("Connection Error",
                  style: TextStyle(fontSize: 24)),
              dismissOnBackKeyPress: false,
              dismissOnTouchOutside: false,
              btnCancel: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              ),
            ).show();
          }
        });
      } catch (e) {
        //Navigator.pop(context);
        AwesomeDialog(
          context: context,
          title: "Error",
          body: Text(e.toString(), style: const TextStyle(fontSize: 24)),
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          btnCancel: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ).show();
      }
    }
  }

  signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    FirebaseAuth.instance.signInWithCredential(credential).then((user) {

      FirebaseFirestore.instance.collection("users").where("uId", isEqualTo: user.user!.uid).get().then((value){
        if (value.docs.isEmpty){
          FirebaseFirestore.instance.collection("users").add({
            "withPassword":false,
            "uId":user.user!.uid,
          }).then((value){
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SetPasswordForGoogleScreen(),
                ),
                    (route) => false);
          });
        }else{
          value.docs.forEach((element) {
            if (element.data()["withPassword"]){
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                          (route) => false);
            }else{
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SetPasswordForGoogleScreen(),
                  ),
                      (route) => false);
            }
          });
        }
      });

    }).catchError((e) {
      print("=======================================");
      print(e.toString());
      print("=======================================");
    });
  }
}
