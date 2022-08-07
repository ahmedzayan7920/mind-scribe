import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/screens/home_screen.dart';
import 'package:flutterfirebase/screens/login_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);


  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? timer;
  bool isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        checkEmailVerified();
      });
    } else {

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>  const HomeScreen(),
          ),
              (route) => false);
    }
  }

  Future sendVerificationEmail() async {
    await FirebaseAuth.instance.currentUser!.sendEmailVerification();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  checkEmailVerified() {
    FirebaseAuth.instance.currentUser!.reload().then((value) {
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
      if (isEmailVerified) {
        timer!.cancel();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text("A verification email has been sent to your email."),
            ElevatedButton.icon(
              onPressed: () {
                if (!isEmailVerified) {
                  sendVerificationEmail();
                  timer = Timer.periodic(const Duration(seconds: 3), (timer) {
                    checkEmailVerified();
                  });
                }
              },
              icon: const Icon(Icons.email),
              label: const Text("Resend Email"),
            ),
            TextButton(
              onPressed: () {
                timer!.cancel();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                        (route) => false);
              },
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}
