import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/screens/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  // late User user;
  //
  // String email = "";
  //
  // getUser() {
  //   user = FirebaseAuth.instance.currentUser!;
  // }
  //
  // addData() {
  //   CollectionReference userRef =
  //       FirebaseFirestore.instance.collection("users");
  //
  //   // with auto ID
  //   // userRef.add({
  //   //   "email": "mahmoud@gmail.com",
  //   //   "username": "mahmoud",
  //   // });
  //
  //   // with Specific ID
  //   userRef.doc("123456789").set({
  //     "email": "yasser@gmail.com",
  //     "username": "yasser",
  //   });
  // }
  //
  // getData() {
  //   // all users
  //   //  FirebaseFirestore.instance.collection("users").where("username", isEqualTo: "zayan").orderBy("username").limit(3).get().then((value){
  //   //   value.docs.forEach((element) {
  //   //     print(element.data());
  //   //   });
  //   // });
  //
  //   // specific user
  //   // FirebaseFirestore.instance.collection("users").doc("9tahq8feF3kyaJxN303B").get().then((value){
  //   //   print(value.data());
  //   // });
  //
  //   // real Time
  //   FirebaseFirestore.instance
  //       .collection("users")
  //       .where("username", isEqualTo: "ahmed")
  //       .snapshots()
  //       .listen((event) {
  //     event.docs.forEach((element) {
  //       setState(() {
  //         email = element.data()["email"];
  //       });
  //     });
  //   });
  // }
  //
  // updateData() {
  //   CollectionReference userRef =
  //       FirebaseFirestore.instance.collection("users");
  //
  //   // known ID
  //   // userRef.doc("123456789").update({
  //   //   "username": "Hello",
  //   // });
  //
  //   userRef.doc("123456789").set(
  //     {
  //       "username":"yasser",
  //     },
  //     SetOptions(merge: true),
  //   );
  // }
  //
  // @override
  // void initState() {
  //   super.initState();
  //   getUser();
  //   getData();
  //   addData();
  //   updateData();
  // }

  CollectionReference usersRef = FirebaseFirestore.instance.collection("users");
  late File file;
  ImagePicker imagePicker = ImagePicker();

  uploadImage() async {
    var imagePicked = await imagePicker.pickImage(source: ImageSource.camera);

    if (imagePicked != null){
      file = File(imagePicked.path);
      String imageName = "${Random().nextInt(1000000000)}${basename(imagePicked.path)}";
      Reference imageRefStorage = FirebaseStorage.instance.ref("images").child(imageName);
      await imageRefStorage.putFile(file).then((p0) async{
        print(await imageRefStorage.getDownloadURL());
      });
    }
  }

  List<String> names = [];

  getAllImages() async {
    var ref =  FirebaseStorage.instance.ref();

    await ref.listAll().then((value){
      value.items.forEach((element) {
        names.add(element.name);
      });

      value.prefixes.forEach((element) {
        ref = ref.child(element.name);

        ref.listAll().then((value){
          value.items.forEach((element) {
            names.add(element.name);
          });

          value.prefixes.forEach((element) {
            ref = ref.child(element.name);

            ref.listAll().then((value){
              value.items.forEach((element) {
                names.add(element.name);
              });
            }).then((value){
              names.forEach((element) {
                print("--------------------");
                print(element.toString());
              });
            });
          });
        });
      });
    });

  }

  @override
  void initState() {
    getAllImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: usersRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text((snapshot.data!.docs[index].data()
                                as Map<String, dynamic>)["username"]),
                            subtitle: Text((snapshot.data!.docs[index].data()
                                as Map<String, dynamic>)["email"]),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 15);
                        },
                        itemCount: snapshot.data!.docs.length);
                  } else if (snapshot.hasError) {
                    return const Text("ERROR");
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await uploadImage();
              },
              child: const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}

// child: FutureBuilder<QuerySnapshot>(
// future: usersRef.get(),
// builder: (context, snapshot) {
// if (snapshot.hasData) {
// return ListView.separated(
// itemBuilder: (context, index) {
// return ListTile(
// title: Text((snapshot.data!.docs[index].data()
// as Map<String, dynamic>)["username"]),
// subtitle: Text((snapshot.data!.docs[index].data()
// as Map<String, dynamic>)["email"]),
// );
// },
// separatorBuilder: (context, index) {
// return const SizedBox(height: 15);
// },
// itemCount: snapshot.data!.docs.length);
// } else if (snapshot.hasError) {
// return const Text("ERROR");
// } else {
// return const CircularProgressIndicator();
// }
// },
// ),
