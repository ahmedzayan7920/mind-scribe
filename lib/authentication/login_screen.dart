import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/components/awesome_dialog.dart';
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
      showLoadingDialog(context);
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
          Navigator.pop(context);
          if (e.code == 'user-not-found') {
            showAwesomeDialog(context, "No user found for that email");
          } else if (e.code == 'wrong-password') {
            showAwesomeDialog(context, "Wrong password");
          } else {
            showAwesomeDialog(context, e.toString());
          }
        });
      } catch (e) {
        Navigator.pop(context);
        showAwesomeDialog(context, e.toString());
      }
    }
  }

  signInWithGoogle() async {
    await GoogleSignIn().signIn().then((googleUser) async {
      await googleUser!.authentication.then((googleAuth){
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
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
              }).catchError((e){
                showAwesomeDialog(context, e.toString());
              });
            }else{
              for (var element in value.docs) {
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
              }
            }
          }).catchError((e){
            showAwesomeDialog(context, e.toString());
          });

        }).catchError((e) {
          showAwesomeDialog(context, e.toString());
        });
      }).catchError((e){
        showAwesomeDialog(context, e.toString());
      });
    }).catchError((e){
      showAwesomeDialog(context, e.toString());
    });
  }
}
