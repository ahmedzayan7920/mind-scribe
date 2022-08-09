import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/components/background.dart';

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

  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topLeft,
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
                                    controller: nameController,
                                    validator: (val) {
                                      if (val!.length > 30) {
                                        return "Name can't be more than 30 letters";
                                      } else if (val.length < 3) {
                                        return "Name can't be less than 3 letters";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 43, 91),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(Icons.person_outline,
                                          color:
                                              Color.fromARGB(255, 0, 43, 91)),
                                      hintText: "Name",
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
                              _changeName();
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
    nameController.text = user!.displayName!;
  }

  _changeName() async {
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
                .updateDisplayName(nameController.text)
                .then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            }).catchError((e) {
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
