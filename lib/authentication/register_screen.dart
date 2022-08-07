import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/components/loading_dialog.dart';
import 'package:flutterfirebase/screens/home_screen.dart';
import 'package:flutterfirebase/authentication/verification_screen.dart';
import 'package:flutterfirebase/authentication/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../components/awesome_dialog.dart';
import 'set_password_for_google_screen.dart';

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
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
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
                      decoration: InputDecoration(
                        hintText: "Enter Your NAme",
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
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
                        } else if (val.length < 8) {
                          return "Password can't be less than 8 letter";
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
                          'Already Have Account?',
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text("LOGIN"),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await signUpWithEmailAndPassword();
                      },
                      child: const Text("Register"),
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

  signUpWithEmailAndPassword() async {
    var formData = formState.currentState;
    if (formData!.validate()) {
      formData.save();
      try {
        showLoadingDialog(context);
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        )
            .then((userValue) {
          userValue.user!.updateDisplayName(name);

          FirebaseFirestore.instance.collection("users").add({
            "withPassword":true,
            "uId":userValue.user!.uid,
          }).then((value){
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerificationScreen(),
                ),
                    (route) => false);
          }).catchError((e){
            Navigator.pop(context);
            showAwesomeDialog(context, e.toString());
          });
        }).catchError((e){
          Navigator.pop(context);
          if (e.toString().contains("weak-password")) {
            showAwesomeDialog(context, "The Password is too weak");
          }
          else if (e.toString().contains("email-already-in-use")) {
            showAwesomeDialog(context, "The account already exists for that email");
          } else {
            showAwesomeDialog(context, e.toString());
          }
        });
      } catch (e) {
        Navigator.pop(context);
        if (e.toString().contains("weak-password")) {
          showAwesomeDialog(context, "The Password is too weak");
        }
        else if (e.toString().contains("email-already-in-use")) {
          showAwesomeDialog(context, "The account already exists for that email");
        } else {
          showAwesomeDialog(context, e.toString());
        }
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
