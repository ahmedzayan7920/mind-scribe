import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/loading_dialog.dart';
import '../screens/home_screen.dart';

class SetPasswordForGoogleScreen extends StatefulWidget {
  const SetPasswordForGoogleScreen({Key? key}) : super(key: key);

  @override
  State<SetPasswordForGoogleScreen> createState() => _SetPasswordForGoogleScreenState();
}

class _SetPasswordForGoogleScreenState extends State<SetPasswordForGoogleScreen> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  var user = FirebaseAuth.instance.currentUser;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmationPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Password"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formState,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              TextFormField(
                controller: passwordController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please Enter The New Password";
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  hintText: "Enter Your Password",
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmationPasswordController,
                validator: (val) {
                  if(val!.isEmpty){
                    return "Please Enter The Confirmation Password";
                  }else if (val != passwordController.text){
                    return "Confirmation Password Not Match";
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  hintText: "Enter Your Confirmation Password",
                  labelText: 'Confirmation Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _setPassword();
                },
                child: const Text("Set Password"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                          (route) => false);
                },
                child: const Text("Not Now"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _setPassword(){

    if (formState.currentState!.validate()) {
      showLoading(context);
      FirebaseAuth.instance.currentUser!.updatePassword(passwordController.text).then((value){

        FirebaseFirestore.instance.collection("users").where("uId", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get().then((value){
            value.docs.forEach((element) {
              FirebaseFirestore.instance.collection("users").doc(element.id).update({
                "withPassword":true,
              }).then((value){
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                        (route) => false);
              });
            });

        });
      }).catchError((e){
        Navigator.pop(context);
        if (e.toString().contains("email-already-in-use")){
          AwesomeDialog(
            context: context,
            title: "Error",
            body:  const Text("Email Already in use",
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
        }else if (e.toString().contains("wrong-password")){
          AwesomeDialog(
            context: context,
            title: "Error",
            body:  const Text("Wrong Password",
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

        else{
          AwesomeDialog(
            context: context,
            title: "Error",
            body:  Text(e.toString(),
                style: const TextStyle(fontSize: 24)),
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
    }


  }
}
