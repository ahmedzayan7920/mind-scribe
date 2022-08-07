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
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: formState,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Without Image"),
                  Switch(
                    value: withImage,
                    onChanged: (newVal) {
                      setState(() {
                        withImage = newVal;
                      });
                    },
                  ),
                  const Text("With Image"),
                ],
              ),
              withImage
                  ? GestureDetector(
                      onTap: () {
                        showBottomSheet(context);
                      },
                      child: file == null
                          ? const Icon(
                              Icons.image_outlined,
                              size: 150,
                            )
                          : Image.file(
                              file!,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.fitHeight,
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
                  prefixIcon: Icon(Icons.note),
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
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await addNotes(context);
                },
                child: Text(
                  "Add Note",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ],
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
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                        ),
                        SizedBox(width: 20),
                        Text(
                          "From Gallery",
                          style: TextStyle(fontSize: 20),
                        )
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
                        ),
                        SizedBox(width: 20),
                        Text(
                          "From Camera",
                          style: TextStyle(fontSize: 20),
                        )
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
