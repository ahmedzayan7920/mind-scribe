import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/components/background.dart';

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

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmationPasswordController =
      TextEditingController();

  bool obscureCurrentText = true;
  bool obscureNewText = true;
  bool obscureConfirmationText = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Background(),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * .38,
                  ),
                  SizedBox(
                    height: size.height * .28,
                    child: Stack(
                      children: [
                        Container(
                          height: size.height * .28,
                          margin: EdgeInsets.only(
                            right: size.width * .15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * .30),
                              bottomRight: Radius.circular(size.width * .30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: size.width * .03,
                              ),
                            ],
                          ),
                          child: Form(
                            key: formState,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      left: size.width * .04,
                                      right: size.width * .15),
                                  child: TextFormField(
                                    controller: currentPasswordController,
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return "Please Enter The current Password";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 43, 91),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        Icons.password_outlined,
                                        color: Color.fromARGB(255, 0, 43, 91),
                                      ),
                                      hintText: "Current Password",
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: size.width * .04,
                                      right: size.width * .15),
                                  child: TextFormField(
                                    controller: newPasswordController,
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return "Please Enter The New Password";
                                      } else if ((val.length < 8)) {
                                        return "Password Can't be less than 8 letters";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 43, 91)),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(Icons.password_outlined,
                                          color:
                                          Color.fromARGB(255, 0, 43, 91)),
                                      hintText: "New Password",
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: size.width * .04,
                                      right: size.width * .15),
                                  child: TextFormField(
                                    controller: confirmationPasswordController,
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return "Please Enter The Confirmation Password";
                                      } else if (val != newPasswordController.text) {
                                        return "Confirmation Password Not Match";
                                      } else if ((val.length < 8)) {
                                        return "Password Can't be less than 8 letters";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 43, 91)),
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(Icons.password_outlined,
                                          color:
                                          Color.fromARGB(255, 0, 43, 91)),
                                      hintText: "Confirmation Password",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () async {
                              _changePassword();
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: size.width * .04),
                              height: size.height * .20,
                              width: size.width * .20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color.fromARGB(255, 37, 109, 133),
                                    Color.fromARGB(255, 0, 43, 91),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_outlined,
                                color: Colors.white,
                                size: size.width * .08,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _changePassword() async {
    if (formState.currentState!.validate()) {
      showLoadingDialog(context);
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          var cred = EmailAuthProvider.credential(
              email: user!.email ?? "",
              password: currentPasswordController.text);
          FirebaseAuth.instance.currentUser!
              .reauthenticateWithCredential(cred)
              .then((value) {
            FirebaseAuth.instance.currentUser!
                .updatePassword(newPasswordController.text)
                .then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            }).catchError((e) {
              Navigator.pop(context);
              showAwesomeDialog(context, e.toString());
            });
          }).catchError((e) {
            Navigator.pop(context);
            if (e.toString().contains("wrong-password")) {
              showAwesomeDialog(context, "Wrong Password");
            } else {
              showAwesomeDialog(context, e.toString());
            }
          });
        }
      } on SocketException {
        Navigator.pop(context);
        showAwesomeDialog(context, "No Internet Connection");
      }
    }
  }
}
