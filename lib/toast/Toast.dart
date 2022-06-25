import 'package:flutter/material.dart';

class Toast {
  static sendToast(BuildContext context, String message){
    SnackBar snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1)
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}