import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/loading_dialog.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  var user = FirebaseAuth.instance.currentUser;

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmationPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
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
                controller: currentPasswordController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please Enter The current Password";
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  hintText: "Enter Your Current Password",
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPasswordController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please Enter The New Password";
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  hintText: "Enter Your New Password",
                  labelText: 'New Password',
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
                  }else if (val != newPasswordController.text){
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
                  _changePassword();
                },
                child: const Text("Change Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _changePassword(){

      if (formState.currentState!.validate()) {
        showLoading(context);
        var cred = EmailAuthProvider.credential(email: user!.email??"", password: currentPasswordController.text);
        FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(cred).then((value){
          FirebaseAuth.instance.currentUser!.updatePassword(newPasswordController.text).then((value){
            Navigator.pop(context);
            Navigator.pop(context);
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
        }).catchError((e){
          Navigator.pop(context);
          if (e.toString().contains("wrong-password")){
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
          }else{
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
