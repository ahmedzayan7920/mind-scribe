import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/settings/change_name_screen.dart';
import 'package:image_picker/image_picker.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

import '../components/awesome_dialog.dart';
import '../components/loading_dialog.dart';
import '../settings/change_email_screen.dart';
import '../settings/change_password_screen.dart';
import '../authentication/login_screen.dart';
import '../authentication/verification_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var user = FirebaseAuth.instance.currentUser!;
  late Reference ref;
  File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showBottomSheet(context);
              },
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 100)
                  : CachedNetworkImage(
                      height: 100,
                      width: 100,
                      imageUrl: user.photoURL as String,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person, size: 100),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person, size: 30),
              trailing: const Icon(Icons.edit, size: 30),
              title: const Text("Name", style: TextStyle(color: Colors.grey)),
              subtitle: Text(
                "${user.displayName}",
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              onTap: () async {
                FirebaseFirestore.instance
                    .collection("users")
                    .where("uId", isEqualTo: user.uid)
                    .get()
                    .then((value) {
                  value.docs.forEach((element) async {
                    if (element.data()["withPassword"]) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangeNameScreen(),
                        ),
                      ).then((value) {
                        setState(() {
                          user = FirebaseAuth.instance.currentUser!;
                        });
                      }).catchError((e) {
                        showAwesomeDialog(context, e.toString());
                      });
                    } else {
                      showDialog(
                        context: context,
                        builder: (childContext) {
                          return AlertDialog(
                            title: const Text(
                                "Your Account Doesn't Have Password."),
                            content: const Text(
                                "Are you want to login again and set password?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(childContext);
                                },
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut().then((value) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  }).catchError((e) {
                                    Navigator.pop(childContext);
                                    showAwesomeDialog(context, e.toString());
                                  });
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  });
                }).catchError((e) {
                  showAwesomeDialog(context, e.toString());
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, size: 30),
              trailing: const Icon(Icons.edit, size: 30),
              title: const Text("Email", style: TextStyle(color: Colors.grey)),
              subtitle: Text(
                "${user.email}",
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              onTap: () async {
                FirebaseFirestore.instance
                    .collection("users")
                    .where("uId", isEqualTo: user.uid)
                    .get()
                    .then((value) {
                  value.docs.forEach((element) async {
                    if (element.data()["withPassword"]) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangeEmailScreen(),
                        ),
                      ).then((value) {
                        setState(() {
                          user = FirebaseAuth.instance.currentUser!;
                        });
                        if (!user.emailVerified) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const VerificationScreen(),
                              ),
                              (route) => false);
                        }
                      }).catchError((e) {
                        showAwesomeDialog(context, e.toString());
                      });
                    } else {
                      showDialog(
                        context: context,
                        builder: (childContext) {
                          return AlertDialog(
                            title: const Text(
                                "Your Account Doesn't Have Password."),
                            content: const Text(
                                "Are you want to login again and set password?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(childContext);
                                },
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut().then((value) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  }).catchError((e) {
                                    Navigator.pop(childContext);
                                    showAwesomeDialog(context, e.toString());
                                  });
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  });
                }).catchError((e) {
                  showAwesomeDialog(context, e.toString());
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.password, size: 30),
              trailing: const Icon(Icons.edit, size: 30),
              title:
                  const Text("Password", style: TextStyle(color: Colors.grey)),
              subtitle: const Text(
                "********",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              onTap: () async {
                FirebaseFirestore.instance
                    .collection("users")
                    .where("uId", isEqualTo: user.uid)
                    .get()
                    .then((value) {
                  value.docs.forEach((element) {
                    if (element.data()["withPassword"]) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (childContext) {
                          return AlertDialog(
                            title: const Text(
                                "Your Account Doesn't Have Password."),
                            content: const Text(
                                "Are you want to login again and set password?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(childContext);
                                },
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut().then((value) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  }).catchError((e) {
                                    Navigator.pop(childContext);
                                    showAwesomeDialog(context, e.toString());
                                  });
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  });
                }).catchError((e) {
                  showAwesomeDialog(context, e.toString());
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  showBottomSheet(context) {
    return showModalBottomSheet(
        context: context,
        builder: (childContext) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please Choose Image",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(childContext);
                    ImagePicker()
                        .pickImage(source: ImageSource.gallery)
                        .then((value) {
                      setState(() {
                        file = File(value!.path);
                      });
                      var rand = Random().nextInt(100000);
                      var imageName = "$rand${basename(value!.path)}";
                      ref = FirebaseStorage.instance
                          .ref("images")
                          .child("users")
                          .child(imageName);
                    }).then((value) {
                      changeImage(context);
                    }).catchError((e) {
                      showAwesomeDialog(context, e.toString());
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.photo_outlined,
                          size: 30,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "From Gallery",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(childContext);
                    ImagePicker()
                        .pickImage(source: ImageSource.camera)
                        .then((value) {
                      setState(() {
                        file = File(value!.path);
                      });
                      var rand = Random().nextInt(100000);
                      var imageName = "$rand${basename(value!.path)}";
                      ref = FirebaseStorage.instance
                          .ref("images")
                          .child("users")
                          .child(imageName);
                    }).then((value) {
                      changeImage(context);
                    }).catchError((e) {
                      Navigator.pop(context);
                      showAwesomeDialog(context, e.toString());
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.camera,
                          size: 30,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "From Camera",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  changeImage(context) {
    showLoadingDialog(context);
    if (file == null) {
      return showAwesomeDialog(context, "please choose Image");
    } else {
      ref.putFile(file!).then((p0) {
        ref.getDownloadURL().then((value) {
          if (FirebaseAuth.instance.currentUser!.photoURL != null) {
            String? oldUrl = FirebaseAuth.instance.currentUser!.photoURL!
                    .contains("firebase")
                ? FirebaseAuth.instance.currentUser!.photoURL
                : null;
            if (oldUrl != null) {
              FirebaseStorage.instance.refFromURL(oldUrl).delete().then((val) {
                FirebaseAuth.instance.currentUser!
                    .updatePhotoURL(value)
                    .then((value) {
                  setState(() {
                    user = FirebaseAuth.instance.currentUser!;
                  });

                  Navigator.pop(context);
                }).catchError((e) {
                  Navigator.pop(context);
                  showAwesomeDialog(context, e.toString());
                });
              }).catchError((e) {
                Navigator.pop(context);
                showAwesomeDialog(context, e.toString());
              });
            } else {
              FirebaseAuth.instance.currentUser!
                  .updatePhotoURL(value)
                  .then((value) {
                setState(() {
                  user = FirebaseAuth.instance.currentUser!;
                });
                Navigator.pop(context);
              }).catchError((e) {
                Navigator.pop(context);
                showAwesomeDialog(context, e.toString());
              });
            }
          } else {
            FirebaseAuth.instance.currentUser!
                .updatePhotoURL(value)
                .then((value) {
              setState(() {
                user = FirebaseAuth.instance.currentUser!;
              });

              Navigator.pop(context);
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
