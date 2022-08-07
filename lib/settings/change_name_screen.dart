import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/awesome_dialog.dart';
import '../components/loading_dialog.dart';

class ChangeNameScreen extends StatefulWidget {
  const ChangeNameScreen({Key? key}) : super(key: key);

  @override
  State<ChangeNameScreen> createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  var user = FirebaseAuth.instance.currentUser;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Name"),
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
                controller: nameController,
                validator: (val) {
                  if (val!.length > 30) {
                    return "Name can't be more than 30 letters";
                  }else if (val.length < 3){
                    return "Name can't be less than 3 letters";
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
                  _changeName();
                },
                child: const Text("Change Name"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    nameController.text = user!.displayName!;
  }

  _changeName(){
    if (formState.currentState!.validate()) {
      showLoadingDialog(context);
        var cred = EmailAuthProvider.credential(email: user!.email??"", password: passwordController.text);
        FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(cred).then((value){
          FirebaseAuth.instance.currentUser!.updateDisplayName(nameController.text).then((value){
            Navigator.pop(context);
            Navigator.pop(context);
          }).catchError((e){
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
