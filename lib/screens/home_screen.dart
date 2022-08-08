import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/components/loading_dialog.dart';
import 'package:flutterfirebase/notes/add_note.dart';
import 'package:flutterfirebase/notes/edit_note.dart';
import 'package:flutterfirebase/notes/note_details_screen.dart';
import 'package:flutterfirebase/screens/settings_screen.dart';

import '../authentication/login_screen.dart';
import '../components/awesome_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var notesRef = FirebaseFirestore.instance.collection("notes");
  var user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: StreamBuilder<QuerySnapshot>(
          stream: notesRef
              .where("userId",
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return NoteDetails(
                              noteData: snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>,
                            );
                          },
                        ),
                      );
                    },
                    child: Card(
                      elevation: 8,
                      child: Row(
                        children: [
                          (snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>)["imageUrl"] !=
                                  ""
                              ? CachedNetworkImage(
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.fill,
                                  imageUrl: (snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>)["imageUrl"],
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.note_alt_outlined,
                                    size: 80,
                                    color: Color.fromARGB(255, 37, 109, 133),
                                  ),
                                )
                              : const Icon(
                                  Icons.note_alt_outlined,
                                  size: 80,
                                  color: Color.fromARGB(255, 37, 109, 133),
                                ),
                          Expanded(
                            child: ListTile(
                              title: Text(
                                (snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>)["title"],
                                maxLines: 1,
                              ),
                              subtitle: Text(
                                (snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>)["note"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return EditNotes(
                                          noteData: snapshot.data!.docs[index]
                                              .data() as Map<String, dynamic>,
                                          docId: snapshot.data!.docs[index].id,
                                        );
                                      },
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xff256d85),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (childContext) {
                                      return AlertDialog(
                                        title: const Text("Deleting Note..."),
                                        content: const Text(
                                            "Are you sure to delete ?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(childContext);
                                            },
                                            child: const Text("No"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(childContext);
                                              showLoadingDialog(context);
                                              if ((snapshot.data!.docs[index]
                                                              .data()
                                                          as Map<String,
                                                              dynamic>)[
                                                      "imageUrl"] !=
                                                  "") {
                                                FirebaseStorage.instance
                                                    .refFromURL(
                                                        (snapshot.data!
                                                                    .docs[index]
                                                                    .data()
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "imageUrl"])
                                                    .delete()
                                                    .then((value) {
                                                  notesRef
                                                      .doc(snapshot
                                                          .data!.docs[index].id)
                                                      .delete()
                                                      .then((value) {
                                                    Navigator.pop(context);
                                                  });
                                                }).catchError((e) {
                                                  Navigator.pop(context);
                                                  showAwesomeDialog(
                                                      context, e.toString());
                                                });
                                              } else {
                                                notesRef
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .delete()
                                                    .then((value) {
                                                  Navigator.pop(context);
                                                }).catchError((e) {
                                                  Navigator.pop(context);
                                                  showAwesomeDialog(
                                                      context, e.toString());
                                                });
                                              }
                                            },
                                            child: const Text("Yes"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 12);
                },
                itemCount: snapshot.data!.docs.length,
              );
            } else if (snapshot.hasError) {
              return showAwesomeDialog(context, "ERROR");
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNotes(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            user!.photoURL == null
                ? const Icon(Icons.person, size: 100)
                : CachedNetworkImage(
                    height: 100,
                    width: 100,
                    imageUrl: user!.photoURL as String,
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
            const SizedBox(height: 16),
            Text(
              "${user!.displayName}",
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 43, 91),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      size: 30,
                      color: Color.fromARGB(255, 0, 43, 91),
                    ),
                    title:  Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      ).then((value) {
                        setState(() {
                          setState(() {
                            user = FirebaseAuth.instance.currentUser!;
                          });
                        });
                      }).catchError((e) {
                        showAwesomeDialog(context, e.toString());
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      size: 30,
                      color: Color.fromARGB(255, 0, 43, 91),
                    ),
                    title:  Text(
                      "Log out",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      FirebaseAuth.instance.signOut().then((value) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }).catchError((e) {
                        Navigator.pop(context);
                        showAwesomeDialog(context, e.toString());
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
