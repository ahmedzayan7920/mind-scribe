import 'package:cached_network_image/cached_network_image.dart';
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
        title: const Text("Note Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.noteData["imageUrl"] != ""
                ? CachedNetworkImage(
                    height: 300,
                    width: 300,
                    imageUrl: widget.noteData["imageUrl"],
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, size: 120),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.note_alt_outlined,
                    size: 200,
                    color: Color.fromARGB(255, 37, 109, 133),
                  ),
            const SizedBox(
              height: 8,
              width: double.infinity,
            ),
            const SizedBox(
              height: 24,
              width: double.infinity,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.noteData["title"],
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 43, 91),
                  ),
                ),
                const SizedBox(height: 15, width: double.infinity),
                Text(
                  widget.noteData["note"],
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
