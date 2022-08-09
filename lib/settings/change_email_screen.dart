import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/components/background.dart';

import '../components/awesome_dialog.dart';
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

  bool obscureText = true;

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
                    height: size.height * .19,
                    child: Stack(
                      children: [
                        Container(
                          height: size.height * .19,
                          margin: EdgeInsets.only(
                            right: size.width * .15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * .20),
                              bottomRight: Radius.circular(size.width * .20),
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
                                    controller: emailController,
                                    validator: (val) {
                                      if (!EmailValidator.validate(val!)) {
                                        return "Email is Not Valid";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 43, 91),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(Icons.email_outlined,
                                          color:
                                          Color.fromARGB(255, 0, 43, 91),),
                                      hintText: "Email",
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: size.width * .04,
                                      right: size.width * .15),
                                  child: TextFormField(
                                    controller: passwordController,
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return "Please Enter The Password";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 43, 91),
                                    ),
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        Icons.password_outlined,
                                        color: Color.fromARGB(255, 0, 43, 91),
                                      ),
                                      hintText: "Password",
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
                              _changeEmail();
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

  @override
  void initState() {
    super.initState();
    emailController.text = user!.email!;
  }

  _changeEmail() async{
    if (formState.currentState!.validate()) {
      showLoadingDialog(context);
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          var cred = EmailAuthProvider.credential(
              email: user!.email ?? "", password: passwordController.text);
          FirebaseAuth.instance.currentUser!
              .reauthenticateWithCredential(cred)
              .then((value) {
            FirebaseAuth.instance.currentUser!
                .updateEmail(emailController.text)
                .then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            }).catchError((e) {
              Navigator.pop(context);
              if (e.toString().contains("email-already-in-use")) {
                showAwesomeDialog(context, "Email Already in use");
              } else if (e.toString().contains("wrong-password")) {
                showAwesomeDialog(context, "Wrong Password");
              } else {
                showAwesomeDialog(context, e.toString());
              }
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
      } on SocketException{
        Navigator.pop(context);
        showAwesomeDialog(context, "No Internet Connection");
      }


    }
  }
}
