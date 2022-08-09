import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/components/background.dart';

import '../components/awesome_dialog.dart';
import '../components/loading_dialog.dart';
import '../screens/home_screen.dart';

class SetPasswordForGoogleScreen extends StatefulWidget {
  const SetPasswordForGoogleScreen({Key? key}) : super(key: key);

  @override
  State<SetPasswordForGoogleScreen> createState() =>
      _SetPasswordForGoogleScreenState();
}

class _SetPasswordForGoogleScreenState
    extends State<SetPasswordForGoogleScreen> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  var user = FirebaseAuth.instance.currentUser;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmationPasswordController =
      TextEditingController();

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
                  Container(
                    margin: EdgeInsets.only(
                      left: size.width * .08,
                      right: size.width * .08,
                      bottom: size.height * .07,
                      top: size.height * .32,
                    ),
                    child: Text(
                      "Set Password Form Gmail",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 43, 91),
                        fontSize: size.width * .07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                                    controller: passwordController,
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return "Please Enter The New Password";
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 43, 91),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(Icons.password_outlined,
                                          color:
                                              Color.fromARGB(255, 0, 43, 91)),
                                      hintText: "Password",
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
                                      } else if (val !=
                                          passwordController.text) {
                                        return "Confirmation Password Not Match";
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 43, 91),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        Icons.password_outlined,
                                        color: Color.fromARGB(255, 0, 43, 91),
                                      ),
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
                              _setPassword();
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
                  const SizedBox(height: 18),
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
          ],
        ),
      ),
    );
  }

  _setPassword() {
    if (formState.currentState!.validate()) {
      showLoadingDialog(context);
      FirebaseAuth.instance.currentUser!
          .updatePassword(passwordController.text)
          .then((value) {
        FirebaseFirestore.instance
            .collection("users")
            .where("uId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) {
          for (var element in value.docs) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(element.id)
                .update({
              "withPassword": true,
            }).then((value) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                  (route) => false);
            }).catchError((e) {
              Navigator.pop(context);
              showAwesomeDialog(context, e.toString());
            });
          }
        }).catchError((e) {
          Navigator.pop(context);
          showAwesomeDialog(context, e.toString());
        });
      }).catchError((e) {
        Navigator.pop(context);
        showAwesomeDialog(context, e.toString());
      });
    }
  }
}
