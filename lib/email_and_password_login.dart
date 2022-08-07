import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailAndPasswordRegisterScreen extends StatefulWidget {
  const EmailAndPasswordRegisterScreen({Key? key}) : super(key: key);

  @override
  State<EmailAndPasswordRegisterScreen> createState() => _EmailAndPasswordRegisterScreenState();
}

class _EmailAndPasswordRegisterScreenState extends State<EmailAndPasswordRegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Register with Email"),
              onPressed: () async {
                try {
                  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: 'ahmedabdallazayan@gmail.com',
                    password: '123456789',
                  );
                  print(credential.user!.emailVerified);
                  if (credential.user!.emailVerified == false){
                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    print('The password provided is too weak.');
                  } else if (e.code == 'email-already-in-use') {
                    print('The account already exists for that email.');
                  }
                } catch (e) {
                  print(e);
                }
              },
            ),
            ElevatedButton(
              child: const Text("Login with Email"),
              onPressed: () async {
                try {
                  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: 'zayan@gmail.com',
                    password: '123456789',
                  );
                  print(credential.user!.email);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    print('Wrong password provided for that user.');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
