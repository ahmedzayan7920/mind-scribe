import 'package:flutter/material.dart';

showLoading(context) {
  return showDialog(
    context: context,
    builder: (context) {
      return const AlertDialog(
        title: Text("Please Wait.."),
        content: SizedBox(
          width: 80,
          height: 80,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    },
  );
}
