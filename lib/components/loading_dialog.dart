import 'package:flutter/material.dart';

showLoadingDialog(context) {
  return showDialog(
    barrierDismissible: false,
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
