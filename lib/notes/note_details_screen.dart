import 'package:flutter/material.dart';

class NoteDetails extends StatefulWidget {
  const NoteDetails({Key? key, required this.noteData}) : super(key: key);

  final Map<String, dynamic> noteData;

  @override
  State<NoteDetails> createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteData["title"]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.noteData["imageUrl"] != ""?
            Image.network(
              widget.noteData["imageUrl"],
              width: double.infinity,
              height: 300,
              fit: BoxFit.fill,
            ):const SizedBox(width: double.infinity,),
            const SizedBox(height: 8),
            Text(
              widget.noteData["title"],
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.noteData["note"],
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
