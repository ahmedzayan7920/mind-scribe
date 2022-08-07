import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/loading_dialog.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({Key? key}) : super(key: key);

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  var user = FirebaseAuth.instance.currentUser;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.text = user!.email!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Email"),
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
                controller: emailController,
                validator: (val) {
                  if (!EmailValidator.validate(val!)) {
                    return "Email is Not Valid";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.text_format),
                  hintText: "Enter Your Name",
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please Enter The Password";
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
              ElevatedButton(
                onPressed: () {
                  _changeEmail();
                },
                child: const Text("Change Email"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _changeEmail(){
    if (formState.currentState!.validate()) {
      showLoading(context);
        var cred = EmailAuthProvider.credential(email: user!.email??"", password: passwordController.text);
        FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(cred).then((value){
          FirebaseAuth.instance.currentUser!.updateEmail(emailController.text).then((value){
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
