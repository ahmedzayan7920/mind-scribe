import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/awesome_dialog.dart';
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

  bool obscureCurrentText = true;
  bool obscureNewText = true;
  bool obscureConfirmationText = true;

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
                style: const TextStyle( color: Color.fromARGB(255, 0, 43, 91)),
                obscureText: obscureCurrentText,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password, color: Color.fromARGB(255, 0, 43, 91),),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureCurrentText = !obscureCurrentText;
                      });
                    },
                    icon:  Icon(
                      obscureCurrentText?
                      Icons.visibility:Icons.visibility_off,
                      color: const Color.fromARGB(255, 37, 109, 133),
                    ),
                  ),
                  hintText: "Enter Your Current Password",
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: newPasswordController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please Enter The New Password";
                  }else if ((val.length < 8)){
                    return "Password Can't be less than 8 letters";
                  }
                  return null;
                },
                style: const TextStyle( color: Color.fromARGB(255, 0, 43, 91)),
                obscureText: obscureNewText,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password, color: Color.fromARGB(255, 0, 43, 91),),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureNewText = !obscureNewText;
                      });
                    },
                    icon:  Icon(
                      obscureNewText?
                      Icons.visibility:Icons.visibility_off,
                      color: const Color.fromARGB(255, 37, 109, 133),
                    ),
                  ),
                  hintText: "Enter Your New Password",
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
               controller: confirmationPasswordController,
                validator: (val) {
                  if(val!.isEmpty){
                    return "Please Enter The Confirmation Password";
                  }else if (val != newPasswordController.text){
                    return "Confirmation Password Not Match";
                  }else if ((val.length < 8)){
                    return "Password Can't be less than 8 letters";
                  }
                  return null;
                },
                style: const TextStyle( color: Color.fromARGB(255, 0, 43, 91)),
                obscureText: obscureConfirmationText,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password, color: Color.fromARGB(255, 0, 43, 91),),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmationText = !obscureConfirmationText;
                      });
                    },
                    icon:  Icon(
                      obscureConfirmationText?
                      Icons.visibility:Icons.visibility_off,
                      color: const Color.fromARGB(255, 37, 109, 133),
                    ),
                  ),
                  hintText: "Enter Your Confirmation Password",
                  labelText: 'Confirmation Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
        showLoadingDialog(context);
        var cred = EmailAuthProvider.credential(email: user!.email??"", password: currentPasswordController.text);
        FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(cred).then((value){
          FirebaseAuth.instance.currentUser!.updatePassword(newPasswordController.text).then((value){
            Navigator.pop(context);
            Navigator.pop(context);
          }).catchError((e){
            Navigator.pop(context);
            showAwesomeDialog(context, e.toString());
          });
        }).catchError((e){
          Navigator.pop(context);
          if (e.toString().contains("wrong-password")){
            showAwesomeDialog(context, "Wrong Password");
          }else{
            showAwesomeDialog(context, e.toString());
          }
        });
      }


  }
}
