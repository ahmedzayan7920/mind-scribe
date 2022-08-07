import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnonymousLoginScreen extends StatefulWidget {
  const AnonymousLoginScreen({Key? key}) : super(key: key);

  @override
  State<AnonymousLoginScreen> createState() => _AnonymousLoginScreenState();
}

class _AnonymousLoginScreenState extends State<AnonymousLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Anonymous"),
          onPressed: () async {
            try {
              final userCredential =
                  await FirebaseAuth.instance.signInAnonymously();
              print("Signed in with temporary account.");
            } on FirebaseAuthException catch (e) {
              switch (e.code) {
                case "operation-not-allowed":
                  print("Anonymous auth hasn't been enabled for this project.");
                  break;
                default:
                  print("Unknown error.");
              }
            }
          },
        ),
      ),
    );
  }
}
