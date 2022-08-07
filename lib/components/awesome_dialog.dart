

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

showAwesomeDialog(context, text){
  return AwesomeDialog(
    context: context,
    title: "Error",
    body:  Text(text,
        style: const TextStyle(fontSize: 24)),
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    btnCancel: TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text("Close"),
    ),
  ).show();
}