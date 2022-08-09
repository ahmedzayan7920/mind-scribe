import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../components/awesome_dialog.dart';
import '../components/loading_dialog.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({Key? key}) : super(key: key);

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  CollectionReference notesRef = FirebaseFirestore.instance.collection("notes");
  late Reference ref;
  File? file;
  late String title, note;
  bool withImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: formState,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    withImage
                        ? const Text(
                            "Without Image",
                            style: TextStyle(color: Colors.grey),
                          )
                        : const Text(
                            "Without Image",
                            style: TextStyle(
                              color: Color.fromARGB(255, 37, 109, 133),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    Switch(
                      value: withImage,
                      activeColor: const Color.fromARGB(255, 37, 109, 133),
                      onChanged: (newVal) {
                        setState(() {
                          withImage = newVal;
                        });
                      },
                    ),
                    withImage
                        ? const Text(
                            "With Image",
                            style: TextStyle(
                              color: Color.fromARGB(255, 37, 109, 133),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Text(
                            "With Image",
                            style: TextStyle(color: Colors.grey),
                          ),
                  ],
                ),
                withImage
                    ? GestureDetector(
                        onTap: () {
                          showBottomSheet(context);
                        },
                        child: file == null
                            ? const Icon(
                                Icons.add_a_photo_outlined,
                                color: Color.fromARGB(255, 37, 109, 133),
                                size: 150,
                              )
                            : CircleAvatar(
                                backgroundImage: FileImage(file!),
                                radius: 75,
                              ),
                      )
                    : const SizedBox.shrink(),
                TextFormField(
                  validator: (val) {
                    if (val!.length > 30) {
                      return "Title can't to be larger than 30 letter";
                    }
                    if (val.length < 2) {
                      return "Title can't to be less than 2 letter";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    title = val!;
                  },
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: "Title Note",
                    prefixIcon: Icon(
                      Icons.title,
                      color: Color.fromARGB(255, 37, 109, 133),
                    ),
                  ),
                ),
                TextFormField(
                  validator: (val) {
                    if (val!.length > 255) {
                      return "Notes can't to be larger than 255 letter";
                    }
                    if (val.length < 10) {
                      return "Notes can't to be less than 10 letter";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    note = val!;
                  },
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: "Note",
                    prefixIcon: Icon(
                      Icons.note_alt_outlined,
                      color: Color.fromARGB(255, 37, 109, 133),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await addNotes(context);
                  },
                  child: const Text(
                    "Add Note",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  addNotes(context) async {
    if (withImage) {
      if (file == null) {
        return showAwesomeDialog(context, "please choose Image");
      } else {
        var formData = formState.currentState;
        if (formData!.validate()) {
          formData.save();
          showLoadingDialog(context);
          await ref.putFile(file!).then((p0) {
            ref.getDownloadURL().then((value) {
              notesRef.add({
                "title": title,
                "note": note,
                "imageUrl": value,
                "userId": FirebaseAuth.instance.currentUser!.uid
              }).then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
              }).catchError((e) {
                Navigator.pop(context);
                showAwesomeDialog(context, e.toString());
              });
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
    } else {
      var formData = formState.currentState;
      if (formData!.validate()) {
        formData.save();
        showLoadingDialog(context);
        notesRef.add({
          "title": title,
          "note": note,
          "imageUrl": "",
          "userId": FirebaseAuth.instance.currentUser!.uid
        }).then((value) {
          Navigator.pop(context);
          Navigator.pop(context);
        }).catchError((e) {
          Navigator.pop(context);
          showAwesomeDialog(context, e.toString());
        });
      }
    }
  }

  showBottomSheet(context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please Choose Image",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 43, 91),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
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
                          .child("notes")
                          .child(imageName);
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
                          color: Color.fromARGB(255, 0, 43, 91),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "From Gallery",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
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
                          .child("notes")
                          .child(imageName);
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
                          Icons.camera,
                          size: 30,
                          color: Color.fromARGB(255, 0, 43, 91),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "From Camera",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
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
}
